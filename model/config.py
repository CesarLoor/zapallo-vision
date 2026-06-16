"""
ZapalloAI — Configuración centralizada del pipeline de ML.
Todas las rutas y constantes se definen aquí para evitar duplicación.

Uso:
    from config import ROOT, CLASSES, ...  # dentro de model/
    from model.config import ROOT, ...     # desde la raíz del repo
"""

from pathlib import Path
from typing import Final

# ── Resolución de raíz del repositorio ──────────────────────────────
# Busca hacia arriba hasta encontrar la carpeta model/
_CURRENT = Path(__file__).resolve()
ROOT: Final[Path] = max(
    [_CURRENT] + list(_CURRENT.parents),
    key=lambda p: (p / "model").is_dir() and (p / "zapallo_app").is_dir(),
)

# ── Constantes del proyecto ────────────────────────────────────────
PROJECT_NAME: Final[str] = "ZapalloAI"
RANDOM_SEED: Final[int] = 42

# ── Clases (orden ALFABÉTICO = orden que YOLO asigna internamente) ─
CLASSES: Final[list[str]] = [
    "downy_mildew",
    "healthy",
    "leaf_curl",
    "mosaic_virus",
    "red_beetle",
]

# ── Rutas de datos ─────────────────────────────────────────────────
MODEL_DIR: Final[Path] = ROOT / "model"
DATA_DIR: Final[Path] = MODEL_DIR / "data"
RAW_DIR: Final[Path] = DATA_DIR / "raw"
PROCESSED_DIR: Final[Path] = DATA_DIR / "processed"
EXPORT_DIR: Final[Path] = MODEL_DIR / "exports"
SCRIPTS_DIR: Final[Path] = MODEL_DIR / "scripts"
NOTEBOOKS_DIR: Final[Path] = MODEL_DIR / "notebooks"
RUNS_DIR: Final[Path] = MODEL_DIR / "runs" / "classify"

# ── Rutas de datasets raw ──────────────────────────────────────────
CUCURBIT_DIR: Final[Path] = RAW_DIR / "Cucurbit_leaf"
SWEET_DIR: Final[Path] = RAW_DIR / "sweet_pumpkin"
SWEET_AUG_DIR: Final[Path] = SWEET_DIR / "Augmented Images"

# ── Mapeo de nombres de carpetas raw → clases normalizadas ─────────
CUCURBIT_MAP: Final[dict[str, str]] = {
    "Downy mildew":      "downy_mildew",
    "Healthy":           "healthy",
    "Leaf curl disease": "leaf_curl",
    "Mosaic virus":      "mosaic_virus",
}

SWEET_MAP: Final[dict[str, str]] = {
    "Augmented Sweet Pumpkin Downy Mildew Disease": "downy_mildew",
    "Augmented Sweet Pumpkin Healthy Leaf":         "healthy",
    "Augmented Sweet Pumpkin Leaf Curl Disease":    "leaf_curl",
    "Augmented Sweet Pumpkin Mosaic Disease":       "mosaic_virus",
    "Augmented Sweet Pumpkin Red Beetle":           "red_beetle",
}

# ── Parámetros de preprocesamiento ─────────────────────────────────
TRAIN_RATIO: Final[float] = 0.70
VAL_RATIO: Final[float] = 0.15
TEST_RATIO: Final[float] = 0.15

TARGET_PER_CLASS: int | None = None  # None = usar la clase más grande

# ── Parámetros de entrenamiento (GPU 4GB VRAM) ─────────────────────
EPOCHS: Final[int] = 100
IMAGE_SIZE: Final[int] = 224
BATCH_SIZE: int = 4  # se auto-detecta según VRAM
ACCUMULATE: Final[int] = 2  # gradient accumulation steps
AMP: Final[bool] = False
PATIENCE: Final[int] = 15
WORKERS: Final[int] = 0  # Windows requiere workers=0 para multiprocessing

# ── Rutas de exportación Flutter ──────────────────────────────────
FLUTTER_ASSETS: Final[Path] = ROOT / "zapallo_app" / "assets" / "models"
FLUTTER_TFLITE: Final[Path] = FLUTTER_ASSETS / "best_int8.tflite"
FLUTTER_LABELS: Final[Path] = FLUTTER_ASSETS / "labels.txt"

# ── Extensiones de imagen soportadas ──────────────────────────────
IMAGE_EXTENSIONS: Final[tuple[str, ...]] = (
    "*.jpg", "*.jpeg", "*.png",
    "*.JPG", "*.JPEG", "*.PNG",
)


def validar_entorno() -> list[str]:
    """Verifica que las rutas críticas existan. Retorna advertencias."""
    advertencias: list[str] = []

    if not RAW_DIR.exists():
        advertencias.append(f"Dataset raw no encontrado: {RAW_DIR}")

    if not PROCESSED_DIR.exists():
        advertencias.append(
            f"Dataset procesado no encontrado: {PROCESSED_DIR}\n"
            "  Ejecuta: python model/scripts/preprocess.py"
        )

    if not MODEL_DIR.exists():
        advertencias.append(f"Directorio model/ no encontrado: {MODEL_DIR}")

    return advertencias
