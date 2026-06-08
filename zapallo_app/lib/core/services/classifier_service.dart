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

  const ClassificationResult({
    required this.classKey,
    required this.confidence,
    required this.allScores,
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

    // 1. Leer y decodificar la imagen
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw ArgumentError('No se pudo decodificar la imagen: $imagePath');
    }

    // 2. Pre-procesar: resize a 224x224
    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    // 3. Determinar el tipo de entrada del modelo
    final inputTensor = _interpreter!.getInputTensor(0);
    final inputType = inputTensor.type;
    final inputShape = inputTensor.shape; // [1, 224, 224, 3]

    // 4. Preparar buffer de entrada según tipo
    // El tensor del modelo es 4D [1, h, w, 3]; el plugin tflite_flutter
    // acepta un buffer PLANO (1*h*w*3) de tipo Float32List o Uint8List.
    // No envolver en List, o se interpretará como tensor 2D.
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
          (_) => Uint8List(outputShape[1]));
    } else if (outputType == TensorType.int8) {
      output = List.generate(outputShape[0],
          (_) => Int8List(outputShape[1]));
    } else {
      output = List.generate(outputShape[0],
          (_) => Float32List(outputShape[1]));
    }

    // 6. Ejecutar inferencia
    _interpreter!.run(input, output);

    // 7. Extraer probabilidades
    List<double> scores;
    if (outputType == TensorType.uint8) {
      final raw = (output as List<Uint8List>)[0];
      // Dequantize: (value - zeroPoint) * scale
      final params = outputTensor.params;
      scores = raw
          .map((v) => (v - params.zeroPoint) * params.scale)
          .toList();
    } else if (outputType == TensorType.int8) {
      final raw = (output as List<Int8List>)[0];
      final params = outputTensor.params;
      scores = raw
          .map((v) => (v - params.zeroPoint) * params.scale)
          .toList();
    } else {
      scores = (output as List<Float32List>)[0].toList();
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

    return ClassificationResult(
      classKey: _labels[maxIdx],
      confidence: maxVal,
      allScores: allScores,
    );
  }

  /// Convierte la imagen a un buffer Float32 normalizado [0, 1] PLANO
  ///
  /// El modelo `best_int8.tflite` es "weight-only int8" (quantization híbrida):
  /// los pesos están cuantizados en int8, pero las activaciones siguen en float32.
  /// El tensor de entrada es 4D [1, h, w, 3] = 1*h*w*3 = 150528 elementos.
  /// El plugin tflite_flutter requiere un Float32List PLANO (no envuelto en List).
  Float32List _imageToFloat32Buffer(img.Image image, List<int> shape) {
    final h = shape[1];
    final w = shape[2];
    final buffer = Float32List(1 * h * w * 3);
    int idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b.toDouble() / 255.0;
      }
    }
    return buffer;
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
