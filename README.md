# ZapalloVision — Aplicación móvil para detectar enfermedades foliares en zapallo

> Modelo inteligente basado en YOLOv11n-cls para detección automática de enfermedades foliares en plantas de zapallo mediante inferencia en dispositivo (sin internet).

**Universidad de las Fuerzas Armadas ESPE**  
**Estudiantes:** César Loor, Camilo Orrico  
**Docente:** Ing. Doris Chicaiza  
**Fecha:** Junio 2026

---

## Descripción

Aplicación Android offline que permite capturar, validar y clasificar imágenes de hojas de zapallo usando un modelo YOLOv11n-cls cuantizado (int8) ejecutado en el dispositivo via TensorFlow Lite.

### Enfermedades detectadas

| Clave | Clase | Descripción |
|---|---|---|
| `healthy` | Hoja sana | Sin síntomas visibles, coloración uniforme |
| `downy_mildew` | Mildiú velloso | *Pseudoperonospora cubensis* — manchas amarillentas |
| `leaf_curl` | Encrespamiento foliar | Virus del enrollamiento — deformación |
| `mosaic_virus` | Virus del mosaico | Patrones moteados y decoloración |
| `red_beetle` | Escarabajo rojo | Daño por *Aulacophora / Diabrotica* spp. |

---

## Arquitectura del proyecto

```
zapallo-vision/
├── model/                        # Pipeline ML (Python)
│   ├── notebooks/
│   │   ├── 01_exploracion_datos.ipynb
│   │   ├── 02_preprocesamiento.ipynb
│   │   └── 03_entrenamiento_yolov11.ipynb
│   ├── data/                    # Datasets (no versionados)
│   │   ├── raw/                 # Fuentes originales
│   │   └── processed/           # Split train/val/test + augmentation
│   ├── runs/                    # Outputs de entrenamiento
│   └── exports/                 # Modelos exportados
│       ├── best_int8.tflite     # Modelo cuantizado (1.57 MB)
│       ├── labels.txt           # Etiquetas del modelo
│       └── confusion_matrix.png # Matriz de confusión
│
├── zapallo_app/                  # App Flutter
│   ├── lib/
│   │   ├── main.dart            # Entry point
│   │   ├── app.dart             # Router + ClassifierProvider
│   │   ├── config/
│   │   │   ├── constants.dart   # Umbrales, mensajes
│   │   │   ├── disease_info.dart# Base conocimiento 5 enfermedades
│   │   │   ├── routes.dart      # GoRouter (6 rutas)
│   │   │   └── theme.dart       # Tema Outfit, paleta verde
│   │   ├── core/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart    # Drift ORM
│   │   │   │   ├── tables/images_table.dart
│   │   │   │   └── app_database.g.dart  # Generado
│   │   │   └── services/
│   │   │       ├── classifier_service.dart # TFLite inference
│   │   │       ├── image_validator.dart    # Blur + brillo
│   │   │       └── storage_service.dart    # Save/delete
│   │   └── features/
│   │       ├── home/             # Pantalla principal
│   │       ├── capture/          # Cámara + preview + cubit
│   │       ├── diagnosis/        # Resultados + confianza
│   │       └── gallery/          # Galería + detalle + cubit
│   ├── assets/
│   │   ├── models/
│   │   │   ├── best_int8.tflite
│   │   │   └── labels.txt
│   │   ├── fonts/               # Outfit (Regular, Medium, SemiBold, Bold)
│   │   └── images/
│   └── android/                 # Gradle KTS, AGP 9.0.1, JDK 17
│
└── documentacion/               # SRS, HU, paper
```

---

## Tecnologías

| Componente | Tecnología |
|---|---|
| App móvil | Flutter 3.44 + Dart 3.12 |
| Base de datos local | Drift 2.22 (SQLite ORM reactivo) |
| State management | flutter_bloc 9.0 (Cubit + Equatable) |
| Navegación | GoRouter 14.6 |
| Cámara | camera 0.12 (CameraX en Android) |
| Modelo ML | YOLOv11n-cls (Ultralytics) |
| Entrenamiento | Python 3.12 + PyTorch 2.5 + CUDA 12.1 |
| Inferencia móvil | TensorFlow Lite (int8 quantized, 1.57 MB) |
| Validación imagen | Varianza Laplaciano (blur) + luminancia (brillo) |
| Procesamiento img | image 4.5 (Dart) |
| Permisos | permission_handler 11.3 |
| Build | Gradle 9.1 + AGP 9.0.1 + Kotlin 2.3.20 + JDK 17 |

---

## Pipeline de datos

```
Cámara S25+ → JPEG → ImageValidator (blur + brillo) 
    → crop a cuadrado + resize 224×224 
    → uint8 bytes → TFLite interpreter 
    → softmax → ClassificationResult 
    → DiagnosisScreen (enfermedad, confianza, síntomas, recomendaciones)
    → StorageService → disco + SQLite (auto-save)
```

---

## Funcionalidades implementadas

- Captura de fotos con guía de encuadre
- Validación de calidad (borroso, oscuro, sobreexpuesto)
- Clasificación on-device con YOLOv11n-cls (99.48% top-1)
- Auto-guardado silencioso al ver diagnóstico
- Galería local con grid reactivo (Drift stream)
- Detalle de imagen con metadatos, diagnóstico, nitidez
- Banner de baja confianza (<60%)
- Compartir diagnóstico al portapapeles
- Eliminación con confirmación
- Splash screen con carga asíncrona del modelo
- Modo degradado si el modelo no carga
- Sin internet, 100% offline

---

## Mejoras y fixes aplicados

### Build (Samsung S25+)
- JDK 17 forzado via `org.gradle.java.home` y patcheo de Pub cache
- Kotlin JVM target = 17
- AGP 9.0.1 + Kotlin 2.3.20 + Gradle 9.1
- Exclusión de `tensorflow-lite-api` por namespace conflict
- Solo ABI `arm64-v8a` para APK más pequeño
- Build dir redirigido a `zapallo_app/build/` para evitar rutas cross-drive
- `kotlin.incremental=false` para evitar corrupción de cache

### Clasificación TFLite
- Input: `Uint8List` raw bytes en vez de `Float32List` plano (plugin no redimensiona)
- Output: `List<List<double>>` en vez de `Float32List` (type match con plugin)
- Detección automática de tipo de tensor (uint8/int8/float32) + dequantize
- Softmatch condicional (solo si no son ya probabilidades)
- Crop a cuadrado antes de resize para evitar `RangeError` por aspect ratio

### Modelo
- YOLOv11n-cls entrenado desde ImageNet pretrained (10 épocas, AdamW, cosine LR)
- Augmentation: flip, rotate, HSV shift, mixup, erasing
- Exportado a TFLite int8 con calibración (1.57 MB)
- Input: `[1, 224, 224, 3]` uint8 → Output: `[1, 5]` float32
- 99.48% top-1 accuracy en test set (4,778 imágenes)

---

## Inicio rápido

### Requisitos

- Flutter SDK ≥ 3.44
- Android Studio Ladybug Feature Drop (2024.2.2+)
- JDK 17 en `C:\Program Files\Java\jdk-17`
- Dispositivo físico Android 16+ (API 36) o emulador arm64
- Python 3.10+ con PyTorch 2.5+ (solo para re-entrenar)

### Ejecutar la app

```bash
cd zapallo_app
flutter pub get
flutter run
```

### Debug build

```bash
cd zapallo_app
flutter build apk --debug
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### Re-entrenar el modelo

Abrir `model/notebooks/03_entrenamiento_yolov11.ipynb` en PC con GPU (Colab funciona bien).

---

## Documentación

- [SRS IEEE 830](documentacion/SRS_IEEE830_Zapallo_Captura_Imagenes_Version_1.pdf)
- [Historias de Usuario Gherkin](documentacion/Historias_Usuario_Gherkin_Zapallo_Captura_Imagenes_V1.pdf)
- [Paper: Visión Computacional en Cucurbitáceas](documentacion/Detección%20Enfermedades%20Zapallo%20Visión%20Computacional.pdf)

---

## Trabajo futuro

- Aumentar épocas de entrenamiento (20-50) para mejorar accuracy
- Recolectar fotos con S25+ para fine-tuning (reduce data distribution shift)
- Implementar letterbox en vez de crop para alinear con preprocessing de YOLO
- Agregar logging de scores de clasificación en debug
- Ajuste de temperatura para calibración de confianza
- Pruebas unitarias y de integración

---

## Licencia

Proyecto académico — Universidad de las Fuerzas Armadas ESPE, 2026.
