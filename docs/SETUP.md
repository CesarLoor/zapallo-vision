# ============================================================
# INSTRUCCIONES DE CONFIGURACIÓN INICIAL — ZapalloAI
# ============================================================

## 1. FUENTE OUTFIT (OBLIGATORIO para que la UI se vea correctamente)

### Opción A — Descarga manual (recomendada)
1. Ir a: https://fonts.google.com/specimen/Outfit
2. Hacer clic en "Download family" (botón azul, arriba derecha)
3. Descomprimir el ZIP descargado
4. Abrir la carpeta `static/`
5. Copiar estos 4 archivos a `zapallo_app/assets/fonts/`:
   - `Outfit-Regular.ttf`
   - `Outfit-Medium.ttf`
   - `Outfit-SemiBold.ttf`
   - `Outfit-Bold.ttf`

### Opción B — Script PowerShell
Ejecutar desde la carpeta del proyecto:
```powershell
# (Si la conexión a GitHub está disponible)
$dest = "zapallo_app\assets\fonts"
@("Regular","Medium","SemiBold","Bold") | ForEach-Object {
    $url = "https://github.com/google/fonts/raw/main/ofl/outfit/static/Outfit-$_.ttf"
    Invoke-WebRequest $url -OutFile "$dest\Outfit-$_.ttf"
}
```

---

## 2. ANDROID SDK 36 (OBLIGATORIO para compilar para Android)

Flutter 3.44 requiere Android SDK 36. Para instalarlo:

1. Abrir **Android Studio**
2. Ir a `File` → `Settings` → `Languages & Frameworks` → `Android SDK`
3. En la pestaña **SDK Platforms**: marcar `Android 16 (API 36)` → Apply
4. En la pestaña **SDK Tools**: verificar que `Android SDK Build-Tools 35.0.1` está instalado
5. Cerrar Android Studio
6. Aceptar licencias abriendo una terminal y ejecutando:
   ```
   flutter doctor --android-licenses
   ```
   (Presionar `y` para cada licencia)

---

## 3. GOOGLE DRIVE — Datasets (OBLIGATORIO para Sprint 3)

Estructura requerida en Google Drive:
```
Mi unidad/
└── ZapalloAI/
    ├── sweet_pumpkin/     ← Descomprimir Dataset 1 aquí
    └── cucurbit_leaf/     ← Descomprimir Dataset 2 aquí
```

Datasets a descargar (requieren cuenta gratuita de Mendeley Data):
- Dataset 1: https://data.mendeley.com/datasets/bwh3zbpkpv/1
- Dataset 2: https://data.mendeley.com/datasets/zv4cs5rw2v

---

## 4. EJECUTAR LA APP

Una vez resueltos los pasos 1 y 2:
```bash
cd zapallo_app
flutter pub get
flutter run
```

Para compilar el APK de instalación:
```bash
flutter build apk --release
# El APK estará en: build/app/outputs/flutter-apk/app-release.apk
```
