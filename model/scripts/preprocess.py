"""
ZapalloAI — Pipeline de Preprocesamiento de Dataset.

Unifica dos datasets raw (Cucurbit Leaf Disease + Sweet Pumpkin Disease),
deduplica, divide estratificadamente (70/15/15), aumenta clases minoritarias
y genera dataset_final.yaml.

Uso:
    python model/scripts/preprocess.py [--no-aug] [--no-dedup]
"""

from __future__ import annotations

import argparse
import json
import os
import random
import shutil
import sys
from datetime import datetime
from pathlib import Path

import cv2
import numpy as np

try:
    import imagehash
    from PIL import Image
    HAS_DEDUP = True
except ImportError:
    HAS_DEDUP = False

try:
    import albumentations as A  # noqa: N812
    HAS_AUG = True
except ImportError:
    HAS_AUG = False

try:
    from tqdm import tqdm
except ImportError:
    tqdm = None  # type: ignore[assignment]

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from config import (
    CLASSES,
    CUCURBIT_DIR,
    CUCURBIT_MAP,
    IMAGE_EXTENSIONS,
    NOT_LEAF_DIR,
    PROCESSED_DIR,
    RANDOM_SEED,
    SWEET_AUG_DIR,
    SWEET_MAP,
    TARGET_PER_CLASS,
    TRAIN_RATIO,
    VAL_RATIO,
)


def _tqdm(iterable, **kwargs):
    return tqdm(iterable, **kwargs) if tqdm else iterable


# ── Utilidades de archivos ──────────────────────────────────────────


def get_images(folder: Path, recursive: bool = False) -> list[Path]:
    if not folder.exists():
        return []
    result: list[Path] = []
    for ext in IMAGE_EXTENSIONS:
        result.extend(folder.rglob(ext) if recursive else folder.glob(ext))
    return result


def _count_images(p: Path) -> int:
    if not p.exists():
        return 0
    return sum(1 for _ in p.rglob("*.*") if _.suffix.lower() in
               {".jpg", ".jpeg", ".png"})


# ── Etapa 1: Recopilación ──────────────────────────────────────────


def collect_all() -> dict[str, list[Path]]:
    by_cls: dict[str, list[Path]] = {c: [] for c in CLASSES}
    print("\n[1/5] Recopilando imágenes...")

    for folder_name, cls_name in CUCURBIT_MAP.items():
        imgs = get_images(CUCURBIT_DIR / folder_name)
        by_cls[cls_name].extend(imgs)
        print(f"  Cucurbit / {folder_name:<30}: {len(imgs):>5} -> {cls_name}")

    for folder_name, cls_name in SWEET_MAP.items():
        imgs = get_images(SWEET_AUG_DIR / folder_name)
        by_cls[cls_name].extend(imgs)
        print(f"  Sweet    / {folder_name[:30]:<30}: {len(imgs):>5} -> {cls_name}")

    # Negativos reales: personas, manos, herramientas, suelo, frutos, paredes,
    # pantallas y cualquier escena donde una hoja no sea el sujeto principal.
    negatives = get_images(NOT_LEAF_DIR, recursive=True)
    by_cls["not_leaf"].extend(negatives)
    print(f"  Negativos / not_leaf{'':<20}: {len(negatives):>5} -> not_leaf")

    return by_cls


# ── Etapa 2: Deduplicación ─────────────────────────────────────────


def deduplicate(by_cls: dict[str, list[Path]],
                no_dedup: bool = False) -> dict[str, list[Path]]:
    print("\n[2/5] Deduplicando...")
    deduped: dict[str, list[Path]] = {}

    for cls in CLASSES:
        imgs = by_cls[cls]
        if no_dedup or not HAS_DEDUP:
            deduped[cls] = imgs
            status = "sin dedup" if no_dedup else "imagehash no disponible"
            print(f"  {cls:<20}: {len(imgs):>5} ({status})")
            continue

        seen: dict[str, str] = {}
        unique: list[Path] = []
        for p in _tqdm(imgs, desc=f"  {cls:<20}", leave=False):
            try:
                with Image.open(p) as img:
                    h = str(imagehash.phash(img))
                if h not in seen:
                    seen[h] = str(p)
                    unique.append(p)
            except Exception:
                pass

        removed = len(imgs) - len(unique)
        deduped[cls] = unique
        print(f"  {cls:<20}: {len(imgs):>5} → {len(unique):>5} (-{removed})")

    return deduped


# ── Etapa 3: Split + copia ────────────────────────────────────────


def split_and_copy(deduped: dict[str, list[Path]]) -> dict[str, dict[str, int]]:
    print("\n[3/5] Split y copia...")
    random.seed(RANDOM_SEED)

    for split in ("train", "val", "test"):
        for cls in CLASSES:
            (PROCESSED_DIR / split / cls).mkdir(parents=True, exist_ok=True)

    stats: dict[str, dict[str, int]] = {
        cls: {"train": 0, "val": 0, "test": 0} for cls in CLASSES
    }

    for cls in CLASSES:
        imgs = deduped[cls].copy()
        if not imgs:
            raise RuntimeError(
                f"La clase {cls!r} no contiene imágenes. "
                "Agrega datos antes de crear el dataset procesado."
            )
        random.shuffle(imgs)
        n = len(imgs)
        n_train = int(n * TRAIN_RATIO)
        n_val = int(n * VAL_RATIO)

        splits: dict[str, list[Path]] = {
            "train": imgs[:n_train],
            "val": imgs[n_train:n_train + n_val],
            "test": imgs[n_train + n_val:],
        }

        for split_name, split_imgs in splits.items():
            dst_dir = PROCESSED_DIR / split_name / cls
            for img_path in split_imgs:
                if cls == "not_leaf":
                    prefix = "neg"
                else:
                    prefix = "swe" if "sweet_pumpkin" in str(img_path) else "cuc"
                dst = dst_dir / f"{prefix}_{img_path.name}"
                if not dst.exists():
                    shutil.copy2(img_path, dst)
                stats[cls][split_name] += 1

        print(f"  {cls:<20}: train={stats[cls]['train']:>5}, "
              f"val={stats[cls]['val']:>4}, test={stats[cls]['test']:>4}")

    return stats


# ── Etapa 4: Augmentation ──────────────────────────────────────────


def _build_pipeline():
    return A.Compose([
        A.HorizontalFlip(p=0.5),
        A.VerticalFlip(p=0.2),
        A.Rotate(limit=40, p=0.7),
        A.RandomBrightnessContrast(brightness_limit=0.3,
                                    contrast_limit=0.3, p=0.6),
        A.HueSaturationValue(hue_shift_limit=20,
                              sat_shift_limit=40,
                              val_shift_limit=20, p=0.5),
        A.GaussianBlur(blur_limit=(3, 7), p=0.2),
        A.GaussNoise(std_range=(0.04, 0.2), p=0.2),
        A.CoarseDropout(num_holes_range=(1, 6), hole_height_range=(0.1, 0.15), hole_width_range=(0.1, 0.15), p=0.3),
    ])


def augment_minority(stats: dict[str, dict[str, int]],
                     no_aug: bool = False):
    if no_aug or not HAS_AUG:
        print("\n[4/5] Augmentation omitida")
        return

    print("\n[4/5] Aumentando clases minoritarias...")
    pipeline = _build_pipeline()
    target = TARGET_PER_CLASS or max(stats[c]["train"] for c in CLASSES)
    aug_total = 0

    for cls in CLASSES:
        train_dir = PROCESSED_DIR / "train" / cls
        existing = list(train_dir.glob("*.jpg")) + list(train_dir.glob("*.png"))
        current = len(existing)
        needed = max(0, target - current)
        if needed == 0:
            print(f"  OK  {cls:<20}: {current}")
            continue

        print(f"  AUG {cls:<20}: {current} → +{needed}...", end=" ")
        gen = 0
        while gen < needed:
            src = random.choice(existing)
            bgr = cv2.imread(str(src))
            if bgr is None:
                continue
            rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
            aug_rgb = pipeline(image=rgb)["image"]
            aug_bgr = cv2.cvtColor(aug_rgb, cv2.COLOR_RGB2BGR)
            out = train_dir / f"aug_{cls}_{gen:05d}.jpg"
            cv2.imwrite(str(out), aug_bgr, [cv2.IMWRITE_JPEG_QUALITY, 90])
            gen += 1

        aug_total += gen
        print(f"listo ({gen})")

    print(f"  Total augmentadas: +{aug_total}")


# ── Etapa 5: Exportar YAML ────────────────────────────────────────


def save_yaml():
    path = PROCESSED_DIR.parent / "dataset_final.yaml"
    content = f"""# Dataset ZapalloAI — generado por preprocess.py
# Clases en orden alfabético (coincide con YOLO)
path: {PROCESSED_DIR.resolve().as_posix()}
train: train
val: val
test: test

nc: {len(CLASSES)}
names:
"""
    for i, cls in enumerate(CLASSES):
        content += f"  {i}: {cls}\n"

    path.write_text(content, encoding="utf-8")
    print(f"\n[5/5] dataset_final.yaml → {path}")


def save_json_summary(stats: dict[str, dict[str, int]]):
    summary: dict = {
        "timestamp": datetime.now().isoformat(),
        "num_classes": len(CLASSES),
        "classes": CLASSES,
        "per_class": {},
        "total": {"train": 0, "val": 0, "test": 0},
    }

    for cls in CLASSES:
        t, v, ts = stats[cls]["train"], stats[cls]["val"], stats[cls]["test"]
        summary["per_class"][cls] = {"train": t, "val": v, "test": ts, "total": t + v + ts}
        summary["total"]["train"] += t
        summary["total"]["val"] += v
        summary["total"]["test"] += ts

    train_counts = [stats[c]["train"] for c in CLASSES if stats[c]["train"] > 0]
    summary["balance_ratio"] = (
        round(max(train_counts) / min(train_counts), 2) if train_counts else 0
    )
    summary["total_images"] = (
        summary["total"]["train"] + summary["total"]["val"] + summary["total"]["test"]
    )

    path = PROCESSED_DIR.parent / "dataset_summary.json"
    path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\n  dataset_summary.json → {path}")


def print_summary():
    total = sum(_count_images(PROCESSED_DIR / split / cls)
                for split in ("train", "val", "test")
                for cls in CLASSES)
    print(f"\n{'─'*50}")
    print(f"  Total imágenes procesadas: {total:,}")
    print(f"  Dataset listo en          : {PROCESSED_DIR}")
    print(f"{'─'*50}")
    print("\n  Siguiente paso: python model/scripts/train.py\n")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="ZapalloAI — Preprocesamiento de Dataset")
    parser.add_argument("--no-aug", action="store_true",
                        help="Omitir augmentation de datos")
    parser.add_argument("--no-dedup", action="store_true",
                        help="Omitir deduplicación por pHash")
    return parser.parse_args()


def main():
    args = _parse_args()

    os.environ["PYTHONHASHSEED"] = str(RANDOM_SEED)
    random.seed(RANDOM_SEED)
    np.random.seed(RANDOM_SEED)

    print("=" * 50)
    print("  ZapalloAI — Preprocesamiento de Dataset")
    print("=" * 50)

    if not CUCURBIT_DIR.exists() and not SWEET_AUG_DIR.exists():
        print("\nERROR: No se encontraron los datasets raw en:")
        print(f"  {CUCURBIT_DIR}")
        print(f"  {SWEET_AUG_DIR}")
        print("Descarga los datasets de Mendeley Data (ver model/README.md)")
        sys.exit(1)

    by_cls = collect_all()
    deduped = deduplicate(by_cls, no_dedup=args.no_dedup)
    stats = split_and_copy(deduped)
    augment_minority(stats, no_aug=args.no_aug)
    save_yaml()
    save_json_summary(stats)
    print_summary()


if __name__ == "__main__":
    main()
