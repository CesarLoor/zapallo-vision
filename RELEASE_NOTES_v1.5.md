# Release v1.5 — Dashboard, Galería con badges y Detalle con tabs

> **ZapalloVision** — Aplicación Android offline para detección de enfermedades foliares en zapallo usando YOLOv11n-cls cuantizado (int8, 1.57 MB).

**Universidad de las Fuerzas Armadas ESPE**  
**Estudiantes:** César Loor, Camilo Orrico  
**Docente:** Ing. Doris Chicaiza  
**Fecha de release:** Junio 2026

---

## Novedades de v1.5

### Home (Dashboard)
- Dashboard de estadísticas en vivo: total de capturas, hojas sanas, hojas enfermas, último análisis.
- Layout adaptativo con scroll para evitar overflow en pantallas pequeñas.
- Subtítulo dinámico en botón de galería con conteo real.
- Banner de modo degradado si el modelo no carga.

### Galería
- Grid reactivo con paginación (Drift stream, 20 imgs por página).
- Badges de diagnóstico en cada tarjeta: nombre de enfermedad, icono, color.
- Indicador de severidad (dot de color) en tarjetas de hojas enfermas.
- Porcentaje de confianza y mini barra visual en cada tarjeta.
- Animaciones de entrada escalonadas (staggered fade + slide).
- Eliminación con confirmación y feedback háptico.

### Detalle de imagen
- Tab "Reporte": barra de confianza animada, badge de severidad, descripción, síntomas, recomendaciones.
- Tab "Detalles": metadatos técnicos (fecha, ID, tamaño, resolución, nitidez, brillo).
- AppBar con imagen de fondo y overlay de resultado.
- Botón de compartir + botón de eliminar.

### Sistema
- Splash screen con carga asíncrona del modelo TFLite.
- 100% offline — ningún dato sale del dispositivo.
- Validación de imagen pre-clasificación: blur (Laplaciano) + brillo.

---

## Métricas del modelo

| Métrica | Valor |
|---|---|
| Top-1 Accuracy (test) | **99.48%** |
| Top-5 Accuracy (test) | 100% |
| Tamaño del modelo | 1.57 MB (int8) |
| Input | `[1, 224, 224, 3]` uint8 |
| Output | `[1, 5]` float32 |
| Épocas entrenadas | 50 |
| Dataset (train/val/test) | 5,948 / 1,274 / 1,278 (8,500 total) |
| Optimizador | AdamW + cosine LR |
| Augmentation | flip, rotate, HSV, mixup, random erasing |

---

## Clases detectadas

| Clave | Enfermedad |
|---|---|
| `healthy` | Hoja sana |
| `downy_mildew` | Mildiú velloso (*Pseudoperonospora cubensis*) |
| `leaf_curl` | Encrespamiento foliar (Virus del enrollamiento) |
| `mosaic_virus` | Virus del mosaico (ZYMV/CMV) |
| `red_beetle` | Daño por escarabajo rojo (*Aulacophora* spp.) |

---

## Stack técnico

- **App móvil:** Flutter 3.44 + Dart 3.12
- **BD local:** Drift 2.22 (SQLite ORM reactivo)
- **State management:** flutter_bloc 9.0 (Cubit + Equatable)
- **Navegación:** GoRouter 14.6
- **Cámara:** camera 0.12 (CameraX)
- **Modelo ML:** YOLOv11n-cls (Ultralytics) → TFLite int8
- **Build:** Gradle 9.1 + AGP 9.0.1 + Kotlin 2.3.20 + JDK 17

---

## Documentación

- [SRS IEEE 830](documentacion/SRS_IEEE830_Zapallo_Captura_Imagenes_Version_1.pdf)
- [Historias de Usuario Gherkin](documentacion/Historias_Usuario_Gherkin_Zapallo_Captura_Imagenes_V1.pdf)
- [Paper: Visión Computacional en Cucurbitáceas](documentacion/Detecci%C3%B3n%20Enfermedades%20Zapallo%20Visi%C3%B3n%20Computacional.pdf)

---

## Instalación rápida

```bash
git clone https://github.com/CesarLoor/zapallo-vision.git
cd zapallo-vision/zapallo_app
flutter pub get
flutter run
```

Build APK:
```bash
flutter build apk --debug
adb install build\app\outputs\flutter-apk\app-debug.apk
```