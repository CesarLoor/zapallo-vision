# 📋 Guía de Implementación para Android Studio - API 36

## ✅ Cambios Realizados

Este documento resume todos los cambios realizados para compatibilizar la aplicación **ZapalloVision** con:
- **Samsung Galaxy S25+** (Android 16 / API 36)
- **Android Studio** (compilación directa desde IDE)

---

## 🔧 Archivos Modificados

### 1. `android/app/build.gradle.kts`
**Cambios:**
```kotlin
compileSdk = 36  // Android 16 (API 36) para Samsung S25+
targetSdk = 36   // Android 16 (API 36) para Samsung S25+
```

### 2. `android/app/src/main/AndroidManifest.xml`
**Cambios:**
```xml
<!-- Permisos específicos para Android 16 (API 36) -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
```

### 3. `lib/core/services/classifier_service.dart`
**Mejoras:**
- ✅ Validación de existencia de archivo antes de procesar
- ✅ Validación de tamaño mínimo de imagen (10x10 píxeles)
- ✅ Manejo explícito de errores
- ✅ Getters públicos para `modelAsset` y `labelsAsset`

### 4. `lib/core/services/storage_service.dart`
**Mejoras:**
- ✅ Validación de existencia de archivo origen
- ✅ Verificación de copia exitosa
- ✅ Manejo específico de `FileSystemException`
- ✅ Mensajes de error descriptivos

### 5. `lib/core/services/image_validator.dart`
**Mejoras:**
- ✅ Validación de existencia de archivo
- ✅ Validación de tamaño mínimo de imagen
- ✅ Retorno seguro en caso de errores

### 6. `lib/config/constants.dart`
**Mejoras:**
- ✅ Nueva constante `minImageSize = 10`
- ✅ Documentación adicional sobre calibración de umbrales

### 7. `lib/main.dart`
**Mejoras:**
- ✅ Verificación de existencia del modelo TFLite antes de inicializar
- ✅ Función `_checkAssetExists()` para validación de assets

### 8. `lib/core/database/app_database.g.dart` (NUEVO)
**Importante:** Este archivo debe ser generado usando `build_runner`.

---

## 🚀 PASOS PARA COMPILAR EN ANDROID STUDIO

### Paso 1: Abrir el proyecto en Android Studio
1. Abre Android Studio
2. `File` → `Open` → Selecciona `/workspace/zapallo_app`
3. Espera a que Gradle sincronice

### Paso 2: Generar código de Drift (CRÍTICO)

**Opción A: Usando Terminal Integrada**
```bash
cd /workspace/zapallo_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Opción B: Usando Gradle UI**
1. `View` → `Tool Windows` → `Gradle`
2. Expande: `zapallo_app` → `Tasks` → `flutter`
3. Doble clic en `flutterBuildRunner`

**Opción C: Configurar Run Configuration**
1. `Run` → `Edit Configurations`
2. Click `+` → `Flutter Command`
3. Nombre: "Generate Drift DB"
4. Working directory: `/workspace/zapallo_app`
5. Arguments: `pub run build_runner build --delete-conflicting-outputs`

### Paso 3: Configurar API 36 (si no está disponible)

Si Android Studio muestra error de SDK no instalado:

1. `Tools` → `SDK Manager`
2. Pestaña `SDK Platforms`
3. Busca "Android 16 (API 36)" o la versión más reciente disponible
4. Marca la casilla y click `Apply`
5. Si API 36 no está disponible, usa la última API estable (ej. API 35)

> **Nota:** La app funcionará correctamente en tu S25+ incluso si compilas con API 35, ya que `targetSdk` es compatible hacia atrás.

### Paso 4: Conectar tu Samsung S25+

1. Habilita **Opciones de Desarrollador** en tu teléfono:
   - `Ajustes` → `Acerca del teléfono` → `Información de software`
   - Toca `Número de compilación` 7 veces

2. Habilita **Depuración USB**:
   - `Ajustes` → `Opciones de desarrollador` → `Depuración USB` (activar)

3. Conecta el teléfono vía USB
4. En el teléfono, acepta el permiso de depuración

### Paso 5: Compilar y Ejecutar

1. En Android Studio, selecciona tu dispositivo S25+ en la lista de dispositivos
2. Click en el botón ▶️ **Run** (o `Shift + F10`)
3. Espera la compilación (~2-5 minutos la primera vez)

---

## ⚠️ Posibles Problemas y Soluciones

### Error: "app_database.g.dart not found"
**Solución:** Ejecuta `build_runner` (ver Paso 2)

### Error: "SDK not installed" para API 36
**Solución:** 
- Instala API 36 desde SDK Manager, O
- Cambia temporalmente a API 35 en `build.gradle.kts`:
  ```kotlin
  compileSdk = 35
  targetSdk = 35
  ```

### Error: "Model file not found"
**Verifica:**
```bash
ls -la /workspace/zapallo_app/assets/models/best_int8.tflite
```
El archivo debe existir y pesar ~1.6 MB.

### Error: "Permission denied" al guardar imágenes
**Solución:** Asegúrate de conceder permisos de cámara y almacenamiento cuando la app los solicite.

---

## 📊 Resumen de Mejoras de Robustez

| Componente | Mejora | Impacto |
|------------|--------|---------|
| `ClassifierService` | Validación de archivo y tamaño | Previene crashes por imágenes corruptas |
| `StorageService` | Try-catch específico + verificación de copia | Mejor diagnóstico de errores |
| `ImageValidator` | Validación de existencia y tamaño | Evita procesamiento de imágenes inválidas |
| `main.dart` | Verificación de modelo TFLite | Detecta problemas de assets temprano |
| `AndroidManifest` | Permiso Android 16 | Compatibilidad con S25+ |
| `build.gradle.kts` | API 36 explícita | Optimización para dispositivo objetivo |

---

## 🎯 Pruebas Recomendadas

1. **Prueba de cámara:** Captura imágenes en diferentes condiciones de luz
2. **Prueba de galería:** Selecciona imágenes existentes
3. **Prueba de validación:** Intenta con imágenes borrosas/oscuras
4. **Prueba de persistencia:** Verifica que las imágenes se guardan en la DB
5. **Prueba de inferencia:** Confirma que el diagnóstico funciona offline

---

## 📞 Soporte

Si encuentras errores adicionales:
1. Revisa los logs en `Logcat` (Android Studio)
2. Verifica que `app_database.g.dart` esté generado
3. Confirma que el modelo TFLite esté en `assets/models/`

---

**Última actualización:** 2026
**Dispositivo objetivo:** Samsung Galaxy S25+ (Android 16 / API 36)
