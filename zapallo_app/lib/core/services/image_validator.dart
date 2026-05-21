import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Resultado de la validación de imagen
enum ValidationResult {
  /// La imagen es adecuada para guardar
  acceptable,

  /// La imagen está borrosa (varianza del Laplaciano baja)
  blurry,

  /// La imagen está muy oscura
  tooDark,

  /// La imagen está sobreexpuesta
  tooLight,
}

/// Valida la calidad básica de una imagen capturada.
///
/// Implementa FUN-004 y FUN-005 del SRS IEEE 830:
/// - Detección de borroso mediante varianza del Laplaciano
/// - Detección de baja iluminación mediante brillo promedio
class ImageValidator {
  final double blurThreshold;
  final double brightnessMin;
  final double brightnessMax;

  const ImageValidator({
    this.blurThreshold = 80.0,
    this.brightnessMin = 35.0,
    this.brightnessMax = 225.0,
  });

  /// Valida una imagen desde su ruta de archivo.
  /// Retorna [ValidationResult] y las métricas calculadas.
  Future<ImageValidationReport> validate(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return ImageValidationReport(
        result: ValidationResult.blurry,
        blurScore: 0,
        brightnessScore: 0,
      );
    }

    // Reducir resolución para acelerar cálculo (max 400px)
    final resized = image.width > 400
        ? img.copyResize(image, width: 400)
        : image;

    final grayscale = img.grayscale(resized);

    final blurScore = _computeLaplacianVariance(grayscale);
    final brightnessScore = _computeAverageBrightness(grayscale);

    ValidationResult result;

    if (brightnessScore < brightnessMin) {
      result = ValidationResult.tooDark;
    } else if (brightnessScore > brightnessMax) {
      result = ValidationResult.tooLight;
    } else if (blurScore < blurThreshold) {
      result = ValidationResult.blurry;
    } else {
      result = ValidationResult.acceptable;
    }

    return ImageValidationReport(
      result: result,
      blurScore: blurScore,
      brightnessScore: brightnessScore,
    );
  }

  // ── Cálculo de varianza del Laplaciano ─────────────────────────
  /// Un valor bajo indica imagen borrosa.
  /// Kernel Laplaciano 3x3: [0,1,0,1,-4,1,0,1,0]
  double _computeLaplacianVariance(img.Image gray) {
    final w = gray.width;
    final h = gray.height;

    if (w < 3 || h < 3) return 0.0;

    // Extraer valores de gris en lista plana
    final pixels = List<double>.generate(w * h, (i) {
      final x = i % w;
      final y = i ~/ w;
      return img.getLuminance(gray.getPixel(x, y)).toDouble();
    });

    // Aplicar Laplaciano
    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final lap = pixels[(y - 1) * w + x] +
            pixels[(y + 1) * w + x] +
            pixels[y * w + (x - 1)] +
            pixels[y * w + (x + 1)] -
            4 * pixels[y * w + x];
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0.0;

    final mean = sum / count;
    final variance = sumSq / count - mean * mean;
    return math.max(0.0, variance);
  }

  // ── Cálculo de brillo promedio ─────────────────────────────────
  double _computeAverageBrightness(img.Image gray) {
    double total = 0;
    final w = gray.width;
    final h = gray.height;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        total += img.getLuminance(gray.getPixel(x, y));
      }
    }

    return total / (w * h);
  }
}

/// Reporte de validación con métricas
class ImageValidationReport {
  final ValidationResult result;
  final double blurScore;
  final double brightnessScore;

  const ImageValidationReport({
    required this.result,
    required this.blurScore,
    required this.brightnessScore,
  });

  bool get isAcceptable => result == ValidationResult.acceptable;

  /// Mensaje para mostrar al usuario (SRS §3.4)
  String get userMessage {
    switch (result) {
      case ValidationResult.blurry:
        return 'La imagen no es clara. Intente nuevamente.';
      case ValidationResult.tooDark:
        return 'La imagen está muy oscura. Busque mejor iluminación.';
      case ValidationResult.tooLight:
        return 'La imagen está muy sobreexpuesta. Evite el sol directo.';
      case ValidationResult.acceptable:
        return '';
    }
  }

  @override
  String toString() =>
      'ImageValidationReport(result: $result, blur: ${blurScore.toStringAsFixed(1)}, '
      'brightness: ${brightnessScore.toStringAsFixed(1)})';
}
