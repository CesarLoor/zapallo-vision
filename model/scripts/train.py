"""
ZapalloAI — Entrenamiento YOLOv11n-cls con exportación TFLite.

Ejecuta entrenamiento, validación en test set y exportación a TFLite int8.
El modelo final se copia automáticamente a los assets de Flutter.

Uso:
    python model/scripts/train.py                     # entrenar
    python model/scripts/train.py --resume             # reanudar checkpoint
    python model/scripts/train.py --export-only        # solo exportar TFLite
    python model/scripts/train.py --epochs 50          # cambiar épocas
"""

from __future__ import annotations

import argparse
import csv
import glob
import json
import shutil
import sys
from datetime import datetime
from pathlib import Path


def _check_gpu():
    """Verifica disponibilidad de GPU y configura PyTorch."""
    import torch

    if not torch.cuda.is_available():
        print("ERROR: CUDA no disponible.")
        print("  Verifica: pip show torch")
        print("  Debe decir torch 2.5.x+cu121, no +cpu")
        sys.exit(1)

    gpu_name = torch.cuda.get_device_name(0)
    vram_gb = torch.cuda.get_device_properties(0).total_memory / 1024 ** 3
    print(f"  GPU     : {gpu_name}")
    print(f"  VRAM    : {vram_gb:.1f} GB")

    # Auto batch size según VRAM
    if vram_gb < 6:
        batch = 4
        accumulate = 2
    elif vram_gb < 10:
        batch = 16
        accumulate = 1
    else:
        batch = 32
        accumulate = 1

    torch.backends.cudnn.benchmark = True
    return batch, accumulate


def _validate_dataset(processed_dir: Path) -> bool:
    if not processed_dir.exists():
        print(f"ERROR: Dataset no encontrado: {processed_dir}")
        print("  Ejecuta primero: python model/scripts/preprocess.py")
        return False

    for split in ("train", "val", "test"):
        n = sum(1 for _ in processed_dir.rglob("*.*")
                if _.suffix.lower() in {".jpg", ".jpeg", ".png"})
        if n == 0:
            print(f"ERROR: {split}/ está vacío")
            return False
        print(f"  {split:<5}: {n:,} imágenes")

    return True


def train(args: argparse.Namespace, processed_dir: Path,
          project_dir: Path):
    from ultralytics import YOLO

    model_pt = args.model_pt
    if not Path(model_pt).exists():
        model_pt = "yolo11n-cls.pt"

    model = YOLO(model_pt)
    print(f"\n  Modelo base: {model_pt}")
    print(f"  Épocas     : {args.epochs}")
    print(f"  Batch      : {args.batch}")
    print(f"  Acumular   : {args.accumulate}")
    print(f"  AMP        : {args.amp}")

    model.train(
        data=str(processed_dir),
        epochs=args.epochs,
        imgsz=224,
        batch=args.batch,
        patience=args.patience,
        optimizer="AdamW",
        lr0=0.001,
        lrf=0.01,
        momentum=0.937,
        weight_decay=0.0005,
        warmup_epochs=3,
        cos_lr=True,
        augment=True,
        degrees=30,
        fliplr=0.5,
        flipud=0.3,
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        erasing=0.4,
        mixup=0.1,
        project=str(project_dir),
        name=args.run_name,
        exist_ok=True,
        device=0,
        workers=0,
        amp=args.amp,
        cache=False,
        verbose=True,
    )


def export(args: argparse.Namespace, project_dir: Path,
           export_dir: Path, processed_dir: Path):
    import torch
    from ultralytics import YOLO

    # Buscar el mejor checkpoint
    best = project_dir / args.run_name / "weights" / "best.pt"
    if not best.exists():
        candidates = sorted(project_dir.rglob("weights/best.pt"))
        if candidates:
            best = candidates[-1]
        else:
            print(f"ERROR: No se encontró best.pt en {project_dir}")
            sys.exit(1)

    print(f"\nExportando {best} → TFLite...")
    model = YOLO(str(best))
    model.export(format="tflite", int8=True, imgsz=224, data=str(processed_dir))

    # Copiar TFLite exports
    for f in glob.glob(str(best.parent / "**" / "*.tflite"), recursive=True):
        dst = export_dir / Path(f).name
        shutil.copy2(f, dst)
        mb = Path(f).stat().st_size / 1024 ** 2
        print(f"  {Path(f).name} → {dst} ({mb:.2f} MB)")

    # Generar labels.txt en ORDEN ALFABÉTICO (coincide con YOLO)
    classes = sorted(
        d.name for d in (processed_dir / "train").iterdir() if d.is_dir()
    )
    labels_path = export_dir / "labels.txt"
    labels_path.write_text("\n".join(classes) + "\n", encoding="utf-8")
    print(f"  labels.txt → {labels_path} ({classes})")

    # Validación en test set
    vram_gb = torch.cuda.get_device_properties(0).total_memory / 1024 ** 3
    val_batch = 16 if vram_gb >= 6 else 4
    print("\nValidando en test set...")
    val_results = model.val(
        data=str(processed_dir),
        split="test",
        imgsz=224,
        batch=val_batch,
        device=0,
        workers=0,
        verbose=False,
        plots=True,
    )
    val_metrics = {
        "top1": round(float(val_results.top1), 4) if hasattr(val_results, "top1") else None,
        "top5": round(float(val_results.top5), 4) if hasattr(val_results, "top5") else None,
    }
    val_path = export_dir / "validation_results.json"
    val_path.write_text(json.dumps(val_metrics, indent=2), encoding="utf-8")
    print(f"  Top-1: {val_metrics['top1']}, Top-5: {val_metrics['top5']} → {val_path}")

    # Copiar a assets de Flutter
    flutter_assets = Path(__file__).resolve().parents[2] / "zapallo_app" / "assets" / "models"
    if flutter_assets.exists():
        for f in glob.glob(str(export_dir / "*")):
            if Path(f).is_file():
                shutil.copy2(f, flutter_assets)
                print(f"  → {flutter_assets / Path(f).name}")
        print("Modelo copiado a Flutter assets")
    else:
        print(f"⚠️  No se encontró Flutter assets: {flutter_assets}")
        print("   Copia manualmente:")
        print(f"     {export_dir / 'best_int8.tflite'} → zapallo_app/assets/models/")
        print(f"     {export_dir / 'labels.txt'} → zapallo_app/assets/models/")

    return val_metrics


def _read_best_metrics(run_dir: Path) -> dict:
    """Lee results.csv del entrenamiento y extrae mejores métricas."""
    csv_path = run_dir / "results.csv"
    if not csv_path.exists():
        return {}

    with open(csv_path, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = []
        for row in reader:
            rows.append({k.strip(): v for k, v in row.items()})

    best: dict = {}
    for row in rows:
        try:
            epoch = int(row.get("epoch", 0))
            top1 = float(row.get("metrics/accuracy_top1", 0) or 0)
            top5 = float(row.get("metrics/accuracy_top5", 0) or 0)
            val_loss = float(row.get("val/loss", 0) or 0)
            if not best or top1 > best.get("top1", 0):
                best = {"epoch": epoch, "top1": round(top1, 4),
                        "top5": round(top5, 4), "val_loss": round(val_loss, 4)}
        except (ValueError, TypeError):
            continue
    return best


def save_training_metrics(args: argparse.Namespace,
                          export_dir: Path,
                          project_dir: Path,
                          val_metrics: dict):
    run_dir = project_dir / args.run_name
    best = _read_best_metrics(run_dir)

    metrics = {
        "timestamp": datetime.now().isoformat(),
        "run_name": args.run_name,
        "config": {
            "epochs": args.epochs,
            "batch": args.batch,
            "accumulate": args.accumulate,
            "amp": args.amp,
            "patience": args.patience,
            "model_pt": args.model_pt,
        },
        "best_epoch_metrics": best,
        "test_set_metrics": val_metrics,
        "files": {
            "best_pt": str(run_dir / "weights" / "best.pt"),
            "tflite": str(export_dir / "best_int8.tflite"),
            "labels": str(export_dir / "labels.txt"),
        },
    }

    path = export_dir / "training_metrics.json"
    path.write_text(json.dumps(metrics, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  training_metrics.json → {path}")


def _validate_environment() -> None:
    import importlib.util
    if importlib.util.find_spec("torch") is None:
        print("ERROR: torch no instalado.")
        print("  pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121")
        sys.exit(1)

    try:
        import ultralytics  # noqa: F401
    except ImportError:
        print("ERROR: ultralytics no instalado.")
        print("  pip install 'ultralytics>=8.3.0'")
        sys.exit(1)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="ZapalloAI — Entrenamiento YOLOv11n-cls")

    parser.add_argument("--resume", action="store_true",
                        help="Reanudar entrenamiento desde último checkpoint")
    parser.add_argument("--export-only", action="store_true",
                        help="Solo exportar TFLite desde best.pt existente")
    parser.add_argument("--epochs", type=int, default=100,
                        help="Número de épocas (default: 100)")
    parser.add_argument("--batch", type=int, default=0,
                        help="Batch size (0 = auto-detect)")
    parser.add_argument("--accumulate", type=int, default=0,
                        help="Gradient accumulation steps (0 = auto)")
    parser.add_argument("--patience", type=int, default=15,
                        help="Early stopping patience (default: 15)")
    parser.add_argument("--amp", action="store_true", default=False,
                        help="Activar AMP (no recomendado en GTX 1650)")
    parser.add_argument("--run-name", type=str, default="zapallo_yolov11n",
                        help="Nombre del run (default: zapallo_yolov11n)")
    parser.add_argument("--model-pt", type=str,
                        default="yolo11n-cls.pt",
                        help="Ruta al checkpoint base")

    return parser.parse_args()


def main():
    args = _parse_args()

    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from config import EXPORT_DIR, PROCESSED_DIR, RUNS_DIR

    export_dir = EXPORT_DIR
    export_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 55)
    print("  ZapalloAI — Entrenamiento YOLOv11n-cls")
    print("=" * 55)

    _validate_environment()

    batch, accumulate = _check_gpu()
    if args.batch > 0:
        batch = args.batch
    if args.accumulate > 0:
        accumulate = args.accumulate
    args.batch = batch
    args.accumulate = accumulate

    if not _validate_dataset(PROCESSED_DIR):
        sys.exit(1)

    if not args.export_only:
        train(args, PROCESSED_DIR, RUNS_DIR)

    val_metrics = export(args, RUNS_DIR, export_dir, PROCESSED_DIR)
    save_training_metrics(args, export_dir, RUNS_DIR, val_metrics)

    print()
    print("Pipeline completo.")
    print(f"   Modelo TFLite : {export_dir / 'best_int8.tflite'}")
    print(f"   Labels        : {export_dir / 'labels.txt'}")
    print(f"   Metricas      : {export_dir / 'training_metrics.json'}")


if __name__ == "__main__":
    main()
