import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
    final file = File(imagePath);
    if (!await file.exists()) {
      return ImageValidationReport(
        result: ValidationResult.blurry,
        blurScore: 0,
        brightnessScore: 0,
      );
    }

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return ImageValidationReport(
        result: ValidationResult.blurry,
        blurScore: 0,
        brightnessScore: 0,
      );
    }

    // Validar tamaño mínimo
    if (image.width < 10 || image.height < 10) {
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

    final metrics = await _computeImageMetrics(grayscale);
    final blurScore = metrics.blurScore;
    final brightnessScore = metrics.brightnessScore;

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

  /// Ejecuta ambos cálculos (Laplaciano + brillo) en un isolate separado.
  Future<_ImageMetrics> _computeImageMetrics(img.Image gray) async {
    final w = gray.width;
    final h = gray.height;
    if (w < 3 || h < 3) return _ImageMetrics(0.0, 0.0);

    final pixels = Float64List(w * h);
    for (int i = 0; i < w * h; i++) {
      pixels[i] = img.getLuminance(gray.getPixel(i % w, i ~/ w)).toDouble();
    }
    return compute(_metricsHelper, _MetricsArgs(pixels, w, h));
  }
}

// ── Funciones top-level para compute() ──────────────────────────────

class _MetricsArgs {
  final Float64List pixels;
  final int width;
  final int height;
  const _MetricsArgs(this.pixels, this.width, this.height);
}

class _ImageMetrics {
  final double blurScore;
  final double brightnessScore;
  const _ImageMetrics(this.blurScore, this.brightnessScore);
}

_ImageMetrics _metricsHelper(_MetricsArgs args) {
  final pixels = args.pixels;
  final w = args.width;
  final h = args.height;

  // Laplaciano
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

  final variance = count > 0
      ? math.max(0.0, sumSq / count - (sum / count) * (sum / count))
      : 0.0;

  // Brillo promedio
  double total = 0;
  for (int i = 0; i < pixels.length; i++) {
    total += pixels[i];
  }
  final avgBrightness = total / pixels.length;

  return _ImageMetrics(variance, avgBrightness);
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
