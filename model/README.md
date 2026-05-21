# ML Pipeline - ZapalloAI

Este directorio contiene todo el pipeline de Machine Learning para el entrenamiento y exportación del modelo de detección de enfermedades foliares en zapallo.

## Estructura

```
model/
├── notebooks/
│   ├── 01_exploracion_datos.ipynb      # EDA: distribución, resolución, duplicados
│   ├── 02_preprocesamiento.ipynb       # Unificar datasets, split, augmentation
│   ├── 03_entrenamiento_yolov11.ipynb  # Fine-tuning YOLOv11n-cls
│   ├── 04_evaluacion_metricas.ipynb    # Confusion matrix, F1, per-class
│   └── 05_exportacion_tflite.ipynb     # Export TFLite float32 + int8
├── data/
│   ├── raw/                            # Datasets descargados (no versionados)
│   │   ├── sweet_pumpkin/              # 7,000 imgs (Mendeley Data)
│   │   └── cucurbit_leaf/              # 4,121 imgs (Mendeley Data)
│   ├── processed/                      # Dataset unificado (no versionado)
│   │   ├── train/
│   │   ├── val/
│   │   └── test/
│   └── dataset.yaml                    # Config YOLO
├── runs/                               # Outputs de entrenamiento (no versionados)
├── exports/                            # Modelos exportados
├── requirements.txt
└── README.md
```

## Datasets

| Dataset | Imágenes | Clases | Fuente |
|---|---|---|---|
| Sweet Pumpkin Disease Recognition | 7,000 (aug) | 5 | Mendeley Data |
| Cucurbit Leaf Disease Dataset | 4,121 (aug) | 4 | Mendeley Data |

### Mapeo de clases unificado

| Clase | Sweet Pumpkin | Cucurbit Leaf |
|---|---|---|
| `healthy` | Sana | Sanas |
| `downy_mildew` | Mildiu | Mildiu velloso |
| `leaf_curl` | Enrollamiento foliar | Virus del enrollamiento |
| `mosaic_virus` | Mosaico | Mosaico |
| `red_beetle` | Escarabajo rojo | — |

## Uso en Google Colab

1. Subir los datasets a Google Drive
2. Abrir cada notebook en Colab
3. Conectar con GPU (T4 o superior)
4. Ejecutar las celdas secuencialmente

## Entrenamiento rápido

```python
from ultralytics import YOLO

model = YOLO('yolo11n-cls.pt')
results = model.train(
    data='data/processed',
    epochs=100,
    imgsz=224,
    batch=32,
    patience=15,
    optimizer='AdamW',
)
```

## Exportación a TFLite

```python
model = YOLO('runs/classify/train/weights/best.pt')
model.export(format='tflite', int8=True, imgsz=224)
```
