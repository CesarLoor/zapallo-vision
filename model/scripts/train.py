"""
ZapalloAI — Entrenamiento YOLOv11n-cls en GPU
Ejecutar desde la raiz del repo:
    python model/scripts/train.py
"""
import os, sys
from pathlib import Path


def main():
    # ── Detectar raiz del repo ─────────────────────────────────────
    ROOT = Path(__file__).resolve().parents[2]
    DATA_DIR    = str(ROOT / 'model' / 'data' / 'processed')
    PROJECT_DIR = str(ROOT / 'model' / 'runs' / 'classify')
    EXPORT_DIR  = ROOT / 'model' / 'exports'
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)

    # ── Verificar GPU ──────────────────────────────────────────────
    import torch

    if not torch.cuda.is_available():
        print("ERROR: CUDA no disponible.")
        print("  Verifica: pip show torch  (debe decir 2.5.1+cu121, no +cpu)")
        sys.exit(1)

    GPU_NAME = torch.cuda.get_device_name(0)
    VRAM_GB  = torch.cuda.get_device_properties(0).total_memory / 1024**3

    print("=" * 55)
    print("  ZapalloAI -- Entrenamiento YOLOv11n-cls")
    print("=" * 55)
    print(f"  GPU     : {GPU_NAME}")
    print(f"  VRAM    : {VRAM_GB:.1f} GB")
    print(f"  Dataset : {DATA_DIR}")
    print(f"  Salida  : {PROJECT_DIR}")
    print("=" * 55)

    # Verificar dataset
    data_path = Path(DATA_DIR)
    if not data_path.exists():
        print(f"ERROR: Dataset no encontrado: {DATA_DIR}")
        print("  Ejecuta primero: python model/scripts/preprocess.py")
        sys.exit(1)

    for split in ['train', 'val', 'test']:
        n = sum(1 for _ in (data_path / split).rglob('*.*')) if (data_path / split).exists() else 0
        print(f"  {split:<5}: {n:,} imgs")

    print()

    # ── Entrenamiento ──────────────────────────────────────────────
    from ultralytics import YOLO

    model_pt = ROOT / 'model' / 'notebooks' / 'yolo11n-cls.pt'
    if not model_pt.exists():
        model_pt = 'yolo11n-cls.pt'

    model = YOLO(str(model_pt))

    results = model.train(
        data          = DATA_DIR,
        epochs        = 100,
        imgsz         = 224,
        batch         = 16,
        patience      = 15,
        optimizer     = 'AdamW',
        lr0           = 0.001,
        lrf           = 0.01,
        momentum      = 0.937,
        weight_decay  = 0.0005,
        warmup_epochs = 3,
        cos_lr        = True,
        augment       = True,
        degrees       = 30,
        fliplr        = 0.5,
        flipud        = 0.3,
        hsv_h         = 0.015,
        hsv_s         = 0.7,
        hsv_v         = 0.4,
        erasing       = 0.4,
        mixup         = 0.1,
        project       = PROJECT_DIR,
        name          = 'zapallo_yolov11n_v1',
        exist_ok      = True,
        device        = 0,       # GPU 0 (GTX 1650)
        workers       = 0,       # 0 = sin multiprocessing (requerido en Windows)
        amp           = False,   # Desactivado: GTX 1650 no lo soporta bien
        cache         = False,
        verbose       = True,
    )

    print()
    print("Entrenamiento completado!")
    best = Path(PROJECT_DIR) / 'zapallo_yolov11n_v1' / 'weights' / 'best.pt'
    print(f"Mejor modelo: {best}")

    # ── Exportar a TFLite ──────────────────────────────────────────
    if best.exists():
        print()
        print("Exportando a TFLite...")
        m = YOLO(str(best))
        m.export(format='tflite', imgsz=224)
        m.export(format='tflite', int8=True, imgsz=224, data=DATA_DIR)

        import shutil, glob
        for f in glob.glob(str(best.parent / '**' / '*.tflite'), recursive=True):
            dst = EXPORT_DIR / Path(f).name
            shutil.copy2(f, dst)
            mb = Path(f).stat().st_size / 1024**2
            print(f"  {Path(f).name} -> {dst} ({mb:.2f} MB)")

        lbl = EXPORT_DIR / 'labels.txt'
        lbl.write_text('\n'.join([
            'healthy', 'downy_mildew', 'leaf_curl', 'mosaic_virus', 'red_beetle'
        ]), encoding='utf-8')
        print(f"  labels.txt -> {lbl}")
        print()
        print("Copiar a la app Flutter:")
        print("  zapallo_app/assets/models/best_int8.tflite")
        print("  zapallo_app/assets/models/labels.txt")


# CRITICO en Windows: multiprocessing requiere este guard
if __name__ == '__main__':
    main()
