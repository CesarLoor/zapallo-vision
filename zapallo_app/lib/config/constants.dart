/// Constantes globales de la aplicación ZapalloAI
class AppConstants {
  AppConstants._();

  // ── App info ───────────────────────────────────────────────────
  static const String appName = 'ZapalloAI';
  static const String appVersion = '1.0.0';

  // ── Almacenamiento ─────────────────────────────────────────────
  /// Subcarpeta dentro del directorio de documentos de la app
  static const String imagesFolderName = 'zapallo_images';
  /// Formato de timestamp en nombre de archivo: zapallo_20260521_143022_uuid.jpg
  static const String imageNamePrefix = 'zapallo';
  static const String imageExtension = '.jpg';
  static const int imageQuality = 90; // JPEG quality

  // ── Validación de imagen ────────────────────────────────────────
  /// Varianza del Laplaciano mínima (blur detection).
  /// Valores < umbral = imagen borrosa.
  /// Calibrar con imágenes reales de campo.
  /// NOTA: Estos valores pueden necesitar ajuste según condiciones de iluminación reales.
  static const double blurThreshold = 80.0;

  /// Brillo mínimo (0-255) de la imagen en escala de grises
  static const double brightnessMin = 35.0;
  /// Brillo máximo permitido (sobreexposición)
  static const double brightnessMax = 225.0;
  
  /// Tamaño mínimo de imagen aceptable (ancho y alto en píxeles)
  static const int minImageSize = 10;

  // ── Umbral de confianza del modelo ──────────────────────────────
  /// Confianza mínima (0-1) para considerar confiable un diagnóstico.
  /// Por debajo de este valor se muestra un banner de advertencia.
  static const double minConfidenceThreshold = 0.6;
  static const String msgLowConfidence =
      'Baja confianza en el resultado. Considere tomar otra captura con mejor iluminación.';

  // ── Mensajes del sistema (SRS §3.4) ────────────────────────────
  static const String msgPermissionCamera =
      'Para capturar imágenes debe permitir el acceso a la cámara.';
  static const String msgPermissionStorage =
      'Para guardar imágenes debe permitir el acceso al almacenamiento.';
  static const String msgImageNotClear =
      'La imagen no es clara. Intente nuevamente.';
  static const String msgImageTooDark =
      'La imagen está muy oscura. Busque mejor iluminación.';
  static const String msgImageSaved = 'Imagen guardada correctamente.';
  static const String msgImageSaveError =
      'No se pudo guardar la imagen. Intente nuevamente.';
  static const String msgDeleteConfirm = '¿Desea eliminar esta imagen?';
  static const String msgImageDeleted = 'Imagen eliminada.';
  static const String msgNoImages = 'Aún no hay imágenes almacenadas.';
  static const String msgDeleteError =
      'No se pudo eliminar la imagen. Intente nuevamente.';
  static const String msgAutoSaved = 'Guardado automáticamente';
  static const String msgShareTitle = 'Diagnóstico ZapalloAI';
}
