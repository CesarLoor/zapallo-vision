"""
ZapalloAI — Pipeline de Preprocesamiento
Ejecutar desde la raíz del proyecto:
    python model/scripts/preprocess.py

Estructura esperada:
    model/data/raw/
    ├── Cucurbit_leaf/
    │   ├── Downy mildew/
    │   ├── Healthy/
    │   ├── Leaf curl disease/
    │   └── Mosaic virus/
    └── sweet_pumpkin/
        └── Augmented Images/
            ├── Augmented Sweet Pumpkin Downy Mildew Disease/
            ├── Augmented Sweet Pumpkin Healthy Leaf/
            ├── Augmented Sweet Pumpkin Leaf Curl Disease/
            ├── Augmented Sweet Pumpkin Mosaic Disease/
            └── Augmented Sweet Pumpkin Red Beetle/

Salida:
    model/data/processed/{train,val,test}/{clase}/
    model/data/dataset_final.yaml
"""

import os, sys, shutil, random
from pathlib import Path

# ─── Dependencias opcionales ──────────────────────────────────────
try:
    from PIL import Image
    import imagehash
    DEDUP = True
except ImportError:
    DEDUP = False
    print("[INFO] imagehash no instalado — se omite deduplicación")

try:
    import albumentations as A
    import cv2
    AUG = True
except ImportError:
    AUG = False
    print("[INFO] albumentations/opencv no instalados — se omite augmentation")

# ─── Rutas ────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parents[2]  # raíz del repo
BASE_RAW    = ROOT / "model" / "data" / "raw"
OUTPUT_DIR  = ROOT / "model" / "data" / "processed"

CUCURBIT_DIR  = BASE_RAW / "Cucurbit_leaf"
SWEET_AUG_DIR = BASE_RAW / "sweet_pumpkin" / "Augmented Images"

# ─── Clases y mapeos ──────────────────────────────────────────────
CLASSES = ["healthy", "downy_mildew", "leaf_curl", "mosaic_virus", "red_beetle"]

CUCURBIT_MAP = {
    "Downy mildew":      "downy_mildew",
    "Healthy":           "healthy",
    "Leaf curl disease": "leaf_curl",
    "Mosaic virus":      "mosaic_virus",
}

SWEET_MAP = {
    "Augmented Sweet Pumpkin Downy Mildew Disease": "downy_mildew",
    "Augmented Sweet Pumpkin Healthy Leaf":         "healthy",
    "Augmented Sweet Pumpkin Leaf Curl Disease":    "leaf_curl",
    "Augmented Sweet Pumpkin Mosaic Disease":       "mosaic_virus",
    "Augmented Sweet Pumpkin Red Beetle":           "red_beetle",
}

TRAIN_RATIO = 0.70
VAL_RATIO   = 0.15
RANDOM_SEED = 42
TARGET_PER_CLASS = None  # None = usar la clase más grande como objetivo


def get_images(folder: Path) -> list:
    if not folder.exists():
        return []
    result = []
    for ext in ["*.jpg", "*.jpeg", "*.png", "*.JPG", "*.JPEG", "*.PNG"]:
        result.extend(folder.glob(ext))
    return result


def collect_all() -> dict:
    """Recopila imágenes de ambos datasets."""
    by_cls = {c: [] for c in CLASSES}

    print("\n[1/5] Recopilando imágenes...")
    for folder_name, cls_name in CUCURBIT_MAP.items():
        imgs = get_images(CUCURBIT_DIR / folder_name)
        by_cls[cls_name].extend(imgs)
        print(f"  Cucurbit / {folder_name:<30}: {len(imgs):>5} imgs -> {cls_name}")

    for folder_name, cls_name in SWEET_MAP.items():
        imgs = get_images(SWEET_AUG_DIR / folder_name)
        by_cls[cls_name].extend(imgs)
        print(f"  Sweet    / {folder_name[:30]:<30}: {len(imgs):>5} imgs -> {cls_name}")

    return by_cls


def deduplicate(by_cls: dict) -> dict:
    """Elimina duplicados exactos con pHash."""
    print("\n[2/5] Deduplicando...")
    deduped = {}
    for cls in CLASSES:
        imgs = by_cls[cls]
        if not DEDUP:
            deduped[cls] = imgs
            print(f"  {cls:<20}: {len(imgs)} (sin dedup)")
            continue
        seen, unique = {}, []
        for p in imgs:
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
        print(f"  {cls:<20}: {len(imgs):>5} → {len(unique):>5} únicas (−{removed} dups)")
    return deduped


def split_and_copy(deduped: dict):
    """Split estratificado y copia a processed/."""
    print("\n[3/5] Split y copia...")
    random.seed(RANDOM_SEED)
    stats = {cls: {"train": 0, "val": 0, "test": 0} for cls in CLASSES}

    for split in ["train", "val", "test"]:
        for cls in CLASSES:
            (OUTPUT_DIR / split / cls).mkdir(parents=True, exist_ok=True)

    for cls in CLASSES:
        imgs = deduped[cls].copy()
        random.shuffle(imgs)
        n = len(imgs)
        n_train = int(n * TRAIN_RATIO)
        n_val   = int(n * VAL_RATIO)
        splits = {
            "train": imgs[:n_train],
            "val":   imgs[n_train:n_train + n_val],
            "test":  imgs[n_train + n_val:],
        }
        for split_name, split_imgs in splits.items():
            for img_path in split_imgs:
                prefix = "swe" if "sweet_pumpkin" in str(img_path) else "cuc"
                dst = OUTPUT_DIR / split_name / cls / f"{prefix}_{img_path.name}"
                if not dst.exists():
                    shutil.copy2(img_path, dst)
                stats[cls][split_name] += 1

        print(f"  {cls:<20}: train={stats[cls]['train']:>5}, "
              f"val={stats[cls]['val']:>4}, test={stats[cls]['test']:>4}")
    return stats


def augment_minority(stats: dict):
    """Aumenta clases minoritarias hasta igualar la más grande."""
    if not AUG:
        print("\n[4/5] Augmentation omitida (albumentations no instalado)")
        return

    print("\n[4/5] Augmentation...")
    pipeline = A.Compose([
        A.HorizontalFlip(p=0.5),
        A.VerticalFlip(p=0.2),
        A.Rotate(limit=40, p=0.7),
        A.RandomBrightnessContrast(0.3, 0.3, p=0.6),
        A.HueSaturationValue(20, 40, 20, p=0.5),
        A.GaussianBlur(blur_limit=(3, 7), p=0.2),
        A.GaussNoise(var_limit=(10.0, 50.0), p=0.2),
        A.CoarseDropout(num_holes_range=(1, 6),
                        hole_height_range=(10, 30),
                        hole_width_range=(10, 30), p=0.3),
    ])

    target = TARGET_PER_CLASS or max(stats[c]["train"] for c in CLASSES)
    aug_total = 0

    for cls in CLASSES:
        train_dir = OUTPUT_DIR / "train" / cls
        existing  = list(train_dir.glob("*.jpg")) + list(train_dir.glob("*.png"))
        current   = len(existing)
        needed    = max(0, target - current)
        if needed == 0:
            print(f"  OK  {cls:<20}: {current} imgs")
            continue
        print(f"  AUG {cls:<20}: {current} → +{needed}...")
        gen = 0
        while gen < needed:
            src = random.choice(existing)
            bgr = cv2.imread(str(src))
            if bgr is None:
                continue
            rgb     = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
            aug_rgb = pipeline(image=rgb)["image"]
            aug_bgr = cv2.cvtColor(aug_rgb, cv2.COLOR_RGB2BGR)
            out = train_dir / f"aug_{cls}_{gen:05d}.jpg"
            cv2.imwrite(str(out), aug_bgr, [cv2.IMWRITE_JPEG_QUALITY, 90])
            gen += 1
        aug_total += gen
    print(f"  Total augmentadas: +{aug_total}")


def save_yaml():
    """Guarda dataset_final.yaml."""
    yaml_path = OUTPUT_DIR.parent / "dataset_final.yaml"
    content = f"""# Dataset ZapalloAI — generado por preprocess.py
path: {OUTPUT_DIR.resolve().as_posix()}
train: train
val: val
test: test

nc: 5
names:
  0: healthy
  1: downy_mildew
  2: leaf_curl
  3: mosaic_virus
  4: red_beetle
"""
    with open(yaml_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"\n[5/5] dataset_final.yaml → {yaml_path}")


def print_summary():
    total = sum(
        sum(1 for _ in (OUTPUT_DIR / split / cls).glob("*.*"))
        for split in ["train", "val", "test"]
        for cls in CLASSES
        if (OUTPUT_DIR / split / cls).exists()
    )
    print(f"\n{'─'*50}")
    print(f"  Total imágenes procesadas : {total:,}")
    print(f"  Dataset listo en          : {OUTPUT_DIR}")
    print(f"{'─'*50}")
    print("\n  Siguiente paso: python model/scripts/train.py")
    print("  O ejecutar el Notebook 03 con COLAB_MODE = False\n")


if __name__ == "__main__":
    print("=" * 50)
    print("  ZapalloAI — Preprocesamiento de Dataset")
    print("=" * 50)

    # Verificar que existen los datasets
    if not CUCURBIT_DIR.exists() and not SWEET_AUG_DIR.exists():
        print("\n⛔ ERROR: No se encontraron los datasets en:")
        print(f"   {CUCURBIT_DIR}")
        print(f"   {SWEET_AUG_DIR}")
        sys.exit(1)

    by_cls  = collect_all()
    deduped = deduplicate(by_cls)
    stats   = split_and_copy(deduped)
    augment_minority(stats)
    save_yaml()
    print_summary()
