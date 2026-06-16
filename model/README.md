# ZapalloAI — Pipeline de ML

Clasificador de enfermedades foliares en zapallo usando YOLOv11n-cls.

## Estructura

```
model/
├── config.py              # Configuración centralizada (rutas, clases, hiperparámetros)
├── requirements.txt       # Dependencias Python
├── pyproject.toml         # Ruff + mypy config
├── .gitignore
├── data/
│   ├── raw/               # Datasets originales (no versionados) — descargar de Mendeley
│   ├── processed/         # Dataset unificado procesado (generado por preprocess.py)
│   ├── dataset.yaml       # Config YOLO manual
│   └── dataset_final.yaml # Config YOLO generada por preprocess.py
├── scripts/
│   ├── preprocess.py      # Preprocesamiento: unificación, dedup, split, augment
│   ├── train.py           # Entrenamiento YOLO + export TFLite
│   └── count_images.py    # Utilidad: conteo de imágenes
├── notebooks/
│   ├── 01_exploracion_datos.ipynb
│   ├── 02_preprocesamiento.ipynb
│   └── 03_entrenamiento_yolov11.ipynb
├── exports/               # Modelos exportados (best_int8.tflite, labels.txt)
└── runs/                  # Outputs de entrenamiento YOLO
```

## Pipeline

```
Raw datasets (Mendeley)
    │
    ▼
preprocess.py ──► Unifica, deduplica (pHash), split (70/15/15),
    │               augmenta clases minoritarias, genera dataset_final.yaml
    ▼
train.py ──► YOLOv11n-cls (ImageNet pretrained), exporta TFLite int8,
    │           genera labels.txt, copia a assets de Flutter
    ▼
zapallo_app/assets/models/best_int8.tflite + labels.txt
```

## Clases (orden alfabético = orden YOLO)

| Índice | Clase          | Enfermedad                   |
|--------|----------------|------------------------------|
| 0      | downy_mildew   | Mildiú velloso               |
| 1      | healthy        | Hoja sana                    |
| 2      | leaf_curl      | Virus de la hoja rizada      |
| 3      | mosaic_virus   | Virus del mosaico             |
| 4      | red_beetle     | Daño por escarabajo rojo      |

**Importante:** YOLOv11n-cls asigna índices según el orden alfabético de las
carpetas. `labels.txt` debe mantener este orden para que la app Flutter
interprete correctamente las predicciones.

## Uso

```bash
# 1. Instalar dependencias
pip install -r model/requirements.txt
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# 2. Descargar datasets raw (ver sección abajo)

# 3. Preprocesar
python model/scripts/preprocess.py

# 4. Entrenar
python model/scripts/train.py --epochs 100

# 5. Ver resultados en:
#    model/exports/best_int8.tflite
#    model/exports/labels.txt
```

### Opciones de train.py

| Flag              | Descripción                           | Default  |
|-------------------|---------------------------------------|----------|
| `--epochs N`      | Número de épocas                      | 100      |
| `--batch N`       | Batch size (0 = auto según VRAM)      | 0 (auto) |
| `--resume`        | Reanudar desde último checkpoint       | —        |
| `--export-only`   | Solo exportar TFLite desde best.pt     | —        |
| `--run-name NAME` | Nombre del run de entrenamiento        | zapallo_yolov11n |
| `--amp`           | Activar AMP (no recomendado GTX 1650) | False    |

## Datasets

Descargar de Mendeley Data y extraer en `model/data/raw/`:

- **Cucurbit Leaf Disease Dataset** (4,121 imágenes, 4 clases)
  - https://data.mendeley.com/datasets/k5bchnz7z8/1
- **Sweet Pumpkin Disease Recognition** (7,000 imágenes, 5 clases)
  - https://data.mendeley.com/datasets/3rvmynrctn/1

Estructura esperada después de extraer:

```
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
```

## Exportación TFLite

`train.py` ejecuta automáticamente `model.export(format='tflite', int8=True)`
y copia los archivos a `model/exports/` y a `zapallo_app/assets/models/`.

Para exportación manual (notebook o troubleshooting):

```python
from ultralytics import YOLO
model = YOLO('model/runs/classify/zapallo_yolov11n/weights/best.pt')
model.export(format='tflite', int8=True, imgsz=224)
```

## Calidad de código

```bash
pip install ruff mypy
ruff check model/scripts/ model/config.py
mypy model/scripts/ model/config.py
```
