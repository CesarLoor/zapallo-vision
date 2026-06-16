# ZapalloAI — App Móvil

Detector offline de enfermedades foliares en zapallo (Cucurbita moschata) usando YOLOv11n-cls + TensorFlow Lite.

## Stack

- **Flutter 3.44** / Dart 3.12+
- **flutter_bloc** (Cubit) + Equatable
- **GoRouter** 14.x
- **Drift** (SQLite ORM) 2.22
- **tflite_flutter** 0.12
- **Target:** Android 16 (API 36) — Samsung Galaxy S25+

## Clases de diagnóstico

| Clase | Enfermedad |
|-------|-----------|
| `healthy` | Hoja sana |
| `downy_mildew` | Mildiú velloso |
| `leaf_curl` | Virus de la hoja rizada |
| `mosaic_virus` | Virus del mosaico |
| `red_beetle` | Daño por escarabajo rojo |

## Desarrollo

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Tests

```sh
flutter test
```

## Arquitectura

```
lib/
├── config/        # Constantes, tema, rutas, base de conocimiento
├── core/
│   ├── database/  # Drift ORM (SQLite)
│   ├── services/  # ClassifierService, ImageValidator, StorageService
│   └── repositories/  # Capa de abstracción DB → Cubits
└── features/
    ├── home/       # Pantalla principal
    ├── capture/    # Captura + preview + cubit
    ├── diagnosis/  # Resultados y recomendaciones
    └── gallery/    # Galería + detalle + cubit
```

## Thesis

Proyecto de titulación — Universidad de las Fuerzas Armadas ESPE, 2026.
Autores: César Loor, Camilo Orrico.
