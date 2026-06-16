import 'dart:io';
import 'package:image/image.dart' as img;

/// Crea un archivo de imagen PNG temporal para tests.
///
/// [sharp] controla si la imagen tiene alto contraste (nítida) o es
/// uniforme (borrosa). [brightness] escala el valor promedio de píxel.
String makeTestImage({
  bool sharp = true,
  double brightness = 0.5,
  int width = 100,
  int height = 100,
}) {
  final image = img.Image(width: width, height: height);
  final b = (brightness * 255).round();

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (sharp) {
        final v = (x + y) % 2 == 0 ? b : (b - 30).clamp(0, 255);
        image.setPixelRgba(x, y, v, v, v, 255);
      } else {
        image.setPixelRgba(x, y, b, b, b, 255);
      }
    }
  }

  final dir = Directory.systemTemp.createTempSync('zapallo_test_');
  final file = File('${dir.path}/test_image.png');
  file.writeAsBytesSync(img.encodePng(image));
  return file.path;
}
