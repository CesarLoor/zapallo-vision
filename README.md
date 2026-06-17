# ZapalloVision — Detección de Enfermedades Foliares en Zapallo

> Aplicación Android offline que combina un modelo YOLOv11n-cls cuantizado (int8) con un pipeline Flutter completo para capturar, validar, clasificar y gestionar el historial de diagnósticos foliares en plantas de zapallo — sin conexión a internet.

**Universidad de las Fuerzas Armadas ESPE**  
**Estudiantes:** César Loor, Camilo Orrico  
**Docente:** Ing. Doris Chicaiza  
**Versión:** 1.5 · Junio 2026

---

## Enfermedades detectadas

| Clave | Nombre | Descripción |
|---|---|---|
| `healthy` | Hoja sana | Sin síntomas visibles, coloración verde uniforme |
| `downy_mildew` | Mildiú velloso | *Pseudoperonospora cubensis* — manchas amarillentas angulares |
| `leaf_curl` | Encrespamiento foliar | Virus del enrollamiento (Bemisia tabaci) — deformación foliar |
| `mosaic_virus` | Virus del mosaico | ZYMV/CMV — patrones moteados y ampollas |
| `red_beetle` | Daño por escarabajo rojo | *Aulacophora / Diabrotica* spp. — agujeros irregulares |

---

## Arquitectura del proyecto

```
zapallo-vision/
├── model/                            # Pipeline ML (Python)
│   ├── notebooks/
│   │   ├── 01_exploracion_datos.ipynb
│   │   ├── 02_evaluacion.ipynb
│   │   └── 03_despliegue.ipynb
│   ├── scripts/
│   │   ├── preprocess.py
│   │   └── update_notebooks.py
│   ├── data/                         # Datasets (no versionados)
│   │   └── dataset_summary.json
│   ├── exports/
│   │   ├── best_int8.tflite          # Modelo cuantizado (1.57 MB)
│   │   ├── training_metrics.json
│   │   └── validation_results.json
│   └── runs/                         # Outputs de entrenamiento YOLO
│
├── zapallo_app/                       # App Flutter
│   ├── lib/
│   │   ├── main.dart                 # Entry point
│   │   ├── app.dart                  # ClassifierProvider + _ModelLoader + SplashScreen
│   │   ├── config/
│   │   │   ├── constants.dart        # Umbrales, mensajes del sistema
│   │   │   ├── disease_info.dart     # Base de conocimiento (5 enfermedades)
│   │   │   ├── routes.dart           # GoRouter (6 rutas)
│   │   │   └── theme.dart            # Tema Outfit, paleta verde agrícola
│   │   ├── core/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart       # Drift ORM + queries de estadísticas
│   │   │   │   ├── tables/images_table.dart
│   │   │   │   └── app_database.g.dart     # Generado por build_runner
│   │   │   ├── repositories/
│   │   │   │   ├── capture_repository.dart
│   │   │   │   └── gallery_repository.dart # + DiagnosisStats
│   │   │   ├── services/
│   │   │   │   ├── classifier_service.dart # TFLite inference (dequantize)
│   │   │   │   ├── image_validator.dart    # Blur (Laplaciano) + brillo
│   │   │   │   └── storage_service.dart    # Save/delete en disco + SQLite
│   │   │   ├── di/
│   │   │   │   └── service_locator.dart    # GetIt
│   │   │   └── widgets/
│   │   │       ├── shared_diagnosis_widgets.dart  # Widgets reutilizables de diagnóstico
│   │   │       └── model_error_screen.dart
│   │   └── features/
│   │       ├── home/                 # Dashboard de estadísticas + acciones
│   │       ├── capture/              # Cámara + preview + CaptureCubit
│   │       ├── diagnosis/            # Resultado completo de clasificación
│   │       └── gallery/              # Galería + detalle con tabs + GalleryCubit
│   ├── assets/
│   │   ├── models/
│   │   │   ├── best_int8.tflite
│   │   │   ├── labels.txt
│   │   │   ├── training_metrics.json
│   │   │   └── validation_results.json
│   │   ├── fonts/               # Outfit (Regular, Medium, SemiBold, Bold)
│   │   └── images/
│   └── android/                 # Gradle KTS, AGP 9.0.1, JDK 17
│
└── documentacion/               # SRS, HU, paper académico
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
| DI | get_it 8.0 |
| Build | Gradle 9.1 + AGP 9.0.1 + Kotlin 2.3.20 + JDK 17 |

---

## Pipeline de inferencia

```
Cámara → JPEG
  → ImageValidator (blur < 80 ó brillo fuera de [35, 225] → rechaza)
  → crop cuadrado + resize 224×224
  → uint8 bytes → TFLite interpreter [1, 224, 224, 3]
  → output [1, 5] float32 (dequantize si int8)
  → softmax condicional → ClassificationResult { classKey, confidence, allScores }
  → DiagnosisScreen (enfermedad, confianza, síntomas, recomendaciones)
  → StorageService → copia JPEG a /zapallo_images/ + insert SQLite (auto-save)
```

---

## Funcionalidades

### Flujo principal
- Captura de fotos con guía de encuadre visual (esquinas)
- Validación de calidad automática: blur, oscuridad, sobreexposición
- Clasificación on-device con YOLOv11n-cls — **99.48% top-1** en test set
- Auto-guardado silencioso al ingresar al diagnóstico
- Banner de baja confianza (< 60%) con aviso al usuario
- Compartir diagnóstico como texto al portapapeles (sin emojis, formato limpio)

### Galería (v1.5)
- Grid reactivo con paginación (Drift stream, 20 imgs por página)
- **Badges de diagnóstico** en cada tarjeta: nombre de enfermedad, icono, color
- Indicador de severidad (dot de color) en tarjetas de hojas enfermas
- Porcentaje de confianza y mini barra visual en cada tarjeta
- Animaciones de entrada escalonadas (staggered fade + slide)
- Eliminación con confirmación y feedback háptico

### Detalle de imagen (v1.5)
- **Tab "Reporte"**: barra de confianza animada, badge de severidad, descripción, síntomas, recomendaciones
- **Tab "Detalles"**: metadatos técnicos (fecha, ID, tamaño, resolución, nitidez, brillo)
- AppBar con imagen de fondo y overlay de resultado (igual que DiagnosisScreen)
- Botón de compartir + botón de eliminar

### Home (v1.5)
- **Dashboard de estadísticas**: total de capturas, hojas sanas, hojas enfermas, último análisis
- Layout adaptativo con scroll para evitar overflow en pantallas pequeñas
- Subtítulo dinámico en botón de galería con conteo real

### Sistema
- Splash screen con carga asíncrona del modelo TFLite
- Modo degradado si el modelo no carga (la app sigue funcional)
- 100% offline — ningún dato sale del dispositivo

---

## Métricas del modelo

| Métrica | Valor |
|---|---|
| Top-1 Accuracy (test) | **99.48%** |
| Top-5 Accuracy (test) | 100% |
| Tamaño del modelo | 1.57 MB (int8) |
| Input | `[1, 224, 224, 3]` uint8 |
| Output | `[1, 5]` float32 |
| Épocas entrenadas | 10 |
| Dataset (train/val/test) | ~4,778 imágenes validadas |
| Optimizador | AdamW + cosine LR |
| Augmentation | flip, rotate, HSV, mixup, random erasing |

---

## Inicio rápido

### Requisitos

- Flutter SDK ≥ 3.44
- Android Studio Ladybug Feature Drop (2024.2.2+)
- JDK 17 en `C:\Program Files\Java\jdk-17`
- Dispositivo físico Android (API 36 / Android 16) o emulador arm64
- Python 3.10+ con PyTorch 2.5+ (solo para re-entrenar)

### Ejecutar la app

```bash
cd zapallo_app
flutter pub get
flutter run
```

### Build debug

```bash
cd zapallo_app
flutter build apk --debug
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### Re-entrenar el modelo

Abrir `model/notebooks/03_despliegue.ipynb` en PC con GPU (Google Colab compatible).

---

## Fixes de build conocidos (Samsung S25+ / API 36)

| Problema | Solución aplicada |
|---|---|
| JDK incompatible | `org.gradle.java.home` forzado a JDK 17 en `gradle.properties` |
| Kotlin JVM target mismatch | `jvmTarget = "17"` en todas las tareas Kotlin |
| TFLite namespace conflict | Exclusión de `tensorflow-lite-api` en `build.gradle` |
| APK muy grande | Solo ABI `arm64-v8a` |
| Rutas cross-drive en Windows | Build dir redirigido a `zapallo_app/build/` |
| Cache corruption incremental | `kotlin.incremental=false` |
| Tipo de tensor TFLite | Detección automática uint8/int8/float32 + dequantize condicional |
| RangeError por aspect ratio | Crop cuadrado antes del resize 224×224 |

---

## Documentación

- [SRS IEEE 830](documentacion/SRS_IEEE830_Zapallo_Captura_Imagenes_Version_1.pdf)
- [Historias de Usuario Gherkin](documentacion/Historias_Usuario_Gherkin_Zapallo_Captura_Imagenes_V1.pdf)
- [Paper: Visión Computacional en Cucurbitáceas](documentacion/Detección%20Enfermedades%20Zapallo%20Visión%20Computacional.pdf)

---

## Trabajo futuro

- Aumentar épocas de entrenamiento (20–50) para generalizar mejor
- Recolectar imágenes con S25+ para fine-tuning (reduce distribution shift)
- Implementar letterbox en vez de crop cuadrado (alineación con preprocessing YOLO)
- Agregar filtrado por enfermedad en la galería
- Notas de usuario por captura (campo `notes` ya en BD)
- Estadísticas históricas con gráficos de tendencias
- Ajuste de temperatura para calibración de confianza
- Pruebas unitarias e integración (mocktail ya instalado)
- Exportar reporte PDF con imagen + diagnóstico

---

## Licencia

Proyecto académico — Universidad de las Fuerzas Armadas ESPE, 2026.
