import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Resultado de la clasificación de una imagen
class ClassificationResult {
  final String classKey;
  final double confidence;
  final Map<String, double> allScores;
  final bool isLeaf;
  final String? rejectionReason;

  const ClassificationResult({
    required this.classKey,
    required this.confidence,
    required this.allScores,
    this.isLeaf = true,
    this.rejectionReason,
  });

  @override
  String toString() =>
      'ClassificationResult(class: $classKey, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Servicio de clasificación de enfermedades foliares usando TFLite.
///
/// Carga el modelo `best_int8.tflite` y `labels.txt` desde los assets,
/// pre-procesa la imagen capturada y ejecuta la inferencia.
class ClassifierService {
  static const String _modelAsset = 'assets/models/best_int8.tflite';
  static const String _labelsAsset = 'assets/models/labels.txt';
  static const int _inputSize = 224;
  static const String _notLeafClass = 'not_leaf';
  static const double _minimumConfidence = 0.55;
  static const double _minimumMargin = 0.12;
  
  // Hacer públicos para verificación en main.dart
  static String get modelAsset => _modelAsset;
  static String get labelsAsset => _labelsAsset;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  bool get isReady => _isInitialized;
  List<String> get labels => List.unmodifiable(_labels);

  /// Inicializa el intérprete TFLite y carga las etiquetas.
  /// Debe llamarse una vez al inicio de la app.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar etiquetas
      final labelsData = await rootBundle.loadString(_labelsAsset);
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // Cargar modelo TFLite
      _interpreter = await Interpreter.fromAsset(_modelAsset);

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Clasifica una imagen desde su ruta de archivo.
  /// Retorna [ClassificationResult] con la clase y confianza.
  Future<ClassificationResult> classify(String imagePath) async {
    if (!_isInitialized || _interpreter == null) {
      throw StateError(
          'ClassifierService no inicializado. Llama a initialize() primero.');
    }

    // 1. Validar que el archivo existe
    final file = File(imagePath);
    if (!await file.exists()) {
      throw ArgumentError('El archivo de imagen no existe: $imagePath');
    }

    // 2. Leer y decodificar la imagen
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('No se pudo decodificar la imagen: $imagePath');
    }

    // 3. Validar tamaño mínimo de imagen
    if (image.width < 10 || image.height < 10) {
      throw ArgumentError(
          'Imagen demasiado pequeña (${image.width}x${image.height}). Se requiere al menos 10x10 píxeles.');
    }

    // 4. Pre-procesar: recortar a cuadrado + resize a 224x224
    final size = math.min(image.width, image.height);
    final cropped = img.copyCrop(image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size);
    final resized = img.copyResize(cropped, width: _inputSize, height: _inputSize);

    // 3. Determinar el tipo de entrada del modelo
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputType = inputTensor.type;
    final inputShape = inputTensor.shape; // [1, 224, 224, 3]

    // 4. Preparar buffer de entrada según tipo
    // El tensor del modelo es 4D [1, h, w, 3]; el plugin tflite_flutter
    // acepta raw bytes (Uint8List). NO pasar Float32List plano porque
    // el plugin lo interpreta como 1D [150528] y redimensiona el tensor.
    Object input;
    if (inputType == TensorType.uint8) {
      input = _imageToUint8Buffer(resized, inputShape);
    } else {
      input = _imageToFloat32Buffer(resized, inputShape);
    }

    // 5. Preparar buffer de salida
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape; // [1, 5]
    final outputType = outputTensor.type;

    Object output;
    if (outputType == TensorType.uint8) {
      output = List.generate(outputShape[0],
          (_) => List<int>.filled(outputShape[1], 0));
    } else if (outputType == TensorType.int8) {
      output = List.generate(outputShape[0],
          (_) => List<int>.filled(outputShape[1], 0));
    } else {
      output = List.generate(outputShape[0],
          (_) => List<double>.filled(outputShape[1], 0.0));
    }

    // 6. Ejecutar inferencia
    _interpreter!.run(input, output);

    // 7. Extraer probabilidades
    List<double> scores;
    if (outputType == TensorType.uint8) {
      final raw = (output as List<List<int>>)[0];
      // Dequantize: (value - zeroPoint) * scale
      final params = outputTensor.params;
      scores = raw
          .map((v) => (v - params.zeroPoint) * params.scale)
          .toList();
    } else if (outputType == TensorType.int8) {
      final raw = (output as List<List<int>>)[0];
      final params = outputTensor.params;
      scores = raw
          .map((v) => (v - params.zeroPoint) * params.scale)
          .toList();
    } else {
      scores = (output as List<List<double>>)[0];
    }

    // 8. Aplicar softmax solo si los valores NO son ya probabilidades
    // (el modelo best_int8 ya incluye SOFTMAX al final, por lo que la salida
    //  suele sumar ~1.0; aplicar softmax de nuevo distorsiona las confianzas)
    final sumScores = scores.fold<double>(0.0, (a, b) => a + b);
    if ((sumScores - 1.0).abs() > 0.01) {
      scores = _softmax(scores);
    }

    // 9. Encontrar la clase con mayor probabilidad
    int maxIdx = 0;
    double maxVal = scores[0];
    final allScores = <String, double>{};

    for (int i = 0; i < scores.length && i < _labels.length; i++) {
      allScores[_labels[i]] = scores[i];
      if (scores[i] > maxVal) {
        maxVal = scores[i];
        maxIdx = i;
      }
    }

    final sortedScores = List<double>.from(scores)..sort((a, b) => b.compareTo(a));
    final margin = sortedScores.length > 1
        ? sortedScores[0] - sortedScores[1]
        : sortedScores[0];
    final predictedClass = _labels[maxIdx];
    final isExplicitNegative = predictedClass == _notLeafClass;
    final isUncertain = maxVal < _minimumConfidence || margin < _minimumMargin;
    final isLeaf = !isExplicitNegative && !isUncertain;

    return ClassificationResult(
      classKey: predictedClass,
      confidence: maxVal,
      allScores: allScores,
      isLeaf: isLeaf,
      rejectionReason: isExplicitNegative
          ? 'No se detectó una hoja. Tome de nuevo la imagen.'
          : isUncertain
              ? 'No se pudo confirmar que sea una hoja. Tome de nuevo la imagen.'
              : null,
    );
  }

  /// Convierte la imagen a raw bytes de float32 normalizados [0, 1]
  ///
  /// El modelo `best_int8.tflite` es "weight-only int8" (quantization híbrida):
  /// los pesos están cuantizados en int8, pero las activaciones siguen en float32.
  /// El tensor de entrada es 4D [1, h, w, 3] = 1*h*w*3 = 150528 elementos.
  /// Devolvemos Uint8List (raw bytes) para que tflite_flutter NO intente
  /// redimensionar el tensor (el plugin lo trata como 1D si recibe Float32List).
  Uint8List _imageToFloat32Buffer(img.Image image, List<int> shape) {
    final h = shape[1];
    final w = shape[2];
    final buffer = Float32List(1 * h * w * 3);
    int idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b / 255.0;
      }
    }
    return buffer.buffer.asUint8List();
  }

  /// Convierte la imagen a un buffer Uint8 [0, 255] PLANO
  ///
  /// Misma estructura que _imageToFloat32Buffer pero para modelos con
  /// cuantización completa de activaciones (int8/uint8).
  Uint8List _imageToUint8Buffer(img.Image image, List<int> shape) {
    final h = shape[1];
    final w = shape[2];
    final buffer = Uint8List(1 * h * w * 3);
    int idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        buffer[idx++] = pixel.r.toInt();
        buffer[idx++] = pixel.g.toInt();
        buffer[idx++] = pixel.b.toInt();
      }
    }
    return buffer;
  }

  /// Aplica softmax a los logits de salida
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return logits;

    // Estabilidad numérica: restar el máximo
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExp = exps.fold<double>(0.0, (a, b) => a + b);

    if (sumExp == 0.0) {
      return List.filled(logits.length, 1.0 / logits.length);
    }

    return exps.map((e) => e / sumExp).toList();
  }

  /// Libera recursos del intérprete
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
