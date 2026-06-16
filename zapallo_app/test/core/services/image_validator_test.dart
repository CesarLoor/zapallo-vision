import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zapallo_app/core/services/image_validator.dart';
import '../../helpers/test_image.dart';

void main() {
  late ImageValidator validator;

  setUp(() {
    validator = const ImageValidator(
      blurThreshold: 80.0,
      brightnessMin: 35.0,
      brightnessMax: 225.0,
    );
  });

  group('ImageValidator', () {
    test('validate returns acceptable for a sharp, well-lit image', () async {
      final path = makeTestImage(sharp: true, brightness: 0.5);
      final report = await validator.validate(path);

      expect(report.isAcceptable, isTrue);
      expect(report.blurScore, greaterThan(80.0));
      expect(report.brightnessScore, inInclusiveRange(35, 225));

      File(path).deleteSync();
    });

    test('validate returns blurry for a uniform image', () async {
      final path = makeTestImage(sharp: false, brightness: 0.5);
      final report = await validator.validate(path);

      expect(report.result, ValidationResult.blurry);
      expect(report.blurScore, lessThan(80.0));

      File(path).deleteSync();
    });

    test('validate returns tooDark for a very dark image', () async {
      final path = makeTestImage(sharp: true, brightness: 0.05);
      final report = await validator.validate(path);

      expect(report.result, ValidationResult.tooDark);
      expect(report.brightnessScore, lessThan(35.0));

      File(path).deleteSync();
    });

    test('validate returns tooLight for an overexposed image', () async {
      final path = makeTestImage(sharp: true, brightness: 0.95);
      final report = await validator.validate(path);

      expect(report.result, ValidationResult.tooLight);
      expect(report.brightnessScore, greaterThan(225.0));

      File(path).deleteSync();
    });

    test('validate handles non-existent file gracefully', () async {
      final report = await validator.validate('/non/existent/path.jpg');

      expect(report.isAcceptable, isFalse);
      expect(report.blurScore, 0.0);
      expect(report.brightnessScore, 0.0);
    });

    test('validate handles tiny images', () async {
      final path = makeTestImage(width: 5, height: 5);
      final report = await validator.validate(path);

      expect(report.isAcceptable, isFalse);

      File(path).deleteSync();
    });

    test('userMessage returns appropriate string for each result', () {
      expect(
        ImageValidationReport(
          result: ValidationResult.acceptable,
          blurScore: 100,
          brightnessScore: 128,
        ).userMessage,
        isEmpty,
      );

      expect(
        ImageValidationReport(
          result: ValidationResult.blurry,
          blurScore: 50,
          brightnessScore: 128,
        ).userMessage,
        isNotEmpty,
      );

      expect(
        ImageValidationReport(
          result: ValidationResult.tooDark,
          blurScore: 100,
          brightnessScore: 20,
        ).userMessage,
        contains('oscura'),
      );

      expect(
        ImageValidationReport(
          result: ValidationResult.tooLight,
          blurScore: 100,
          brightnessScore: 240,
        ).userMessage,
        contains('sobreexpuesta'),
      );
    });
  });
}
