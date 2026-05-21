# 🎃 ZapalloAI — Detector Móvil de Enfermedades Foliares en Zapallo

> Modelo inteligente basado en Redes Neuronales Convolucionales para la detección automática de enfermedades foliares en plantas de zapallo mediante una aplicación móvil.

**Universidad de las Fuerzas Armadas ESPE**  
**Estudiantes:** César Loor, Camilo Orrico  
**Docente:** Ing. Doris Chicaiza  
**Fecha:** Mayo 2026

---

## 📋 Descripción

Aplicación móvil Android que permite:

- **V1.0:** Capturar, validar, almacenar y gestionar imágenes de hojas de zapallo de forma local y offline.
- **V2.0:** Detección automática de enfermedades foliares usando YOLOv11n-cls con inferencia en el dispositivo (sin internet).

### Enfermedades detectadas (V2.0)

| Clase | Descripción |
|---|---|
| 🟢 Sana | Hoja sin síntomas visibles |
| 🟡 Mildiu velloso | *Pseudoperonospora cubensis* — manchas amarillentas angulares |
| 🟠 Enrollamiento foliar | Virus del enrollamiento — deformación y curvado de hojas |
| 🔴 Virus del mosaico | Patrones moteados y decoloración |
| 🪲 Escarabajo rojo | Daño por insecto (*Red Beetle*) |

---

## 🏗️ Estructura del Proyecto

```
prototipo_zapallo/
├── documentacion/          # Documentos de tesis (SRS, HU, paper)
├── model/                  # Pipeline ML (Python / Jupyter / Colab)
│   ├── notebooks/          # Jupyter Notebooks
│   ├── data/               # Datasets (no versionados)
│   ├── runs/               # Outputs de entrenamiento
│   └── exports/            # Modelos exportados (TFLite)
├── zapallo_app/            # App Flutter (Android-first)
│   ├── lib/                # Código fuente Dart
│   ├── assets/             # Modelo TFLite, imágenes, fuentes
│   └── test/               # Tests unitarios, widget, integración
└── docs/                   # Documentación técnica adicional
```

---

## 🛠️ Tecnologías

| Componente | Tecnología |
|---|---|
| App móvil | Flutter 3.44 + Dart 3.12 |
| Base de datos local | Drift (SQLite ORM) |
| State management | flutter_bloc (Cubit) |
| Modelo ML | YOLOv11n-cls (Ultralytics) |
| Entrenamiento | Python + Jupyter / Google Colab |
| Inferencia móvil | TensorFlow Lite (int8 quantized) |
| Validación imagen | Laplaciano (blur) + luminancia (brillo) |

---

## 🚀 Inicio rápido

### Requisitos previos

- Flutter SDK ≥ 3.44
- Android SDK 36+ con BuildTools 28.0.3
- Android Studio (para emulador)
- Python 3.10+ (para entrenamiento)

### Ejecutar la app

```bash
cd zapallo_app
flutter pub get
flutter run
```

### Entrenar el modelo (Colab recomendado)

Abrir los notebooks en `model/notebooks/` en Google Colab con GPU habilitada.

---

## 📄 Documentación

- [SRS IEEE 830](documentacion/SRS_IEEE830_Zapallo_Captura_Imagenes_Version_1.pdf)
- [Historias de Usuario Gherkin](documentacion/Historias_Usuario_Gherkin_Zapallo_Captura_Imagenes_V1.pdf)
- [Paper: Visión Computacional en Cucurbitáceas](documentacion/Detección%20Enfermedades%20Zapallo%20Visión%20Computacional.pdf)

---

## 📜 Licencia

Proyecto académico — Universidad de las Fuerzas Armadas ESPE, 2026.
