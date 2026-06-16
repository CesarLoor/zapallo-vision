import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zapallo_app/core/repositories/capture_repository.dart';
import 'package:zapallo_app/core/services/classifier_service.dart';
import 'package:zapallo_app/core/services/image_validator.dart';
import 'package:zapallo_app/core/services/storage_service.dart';
import 'package:zapallo_app/features/capture/cubit/capture_cubit.dart';
import 'package:zapallo_app/features/capture/cubit/capture_state.dart';

class _MockCaptureRepository extends Mock implements CaptureRepository {}

void main() {
  late CaptureRepository repository;
  late CaptureCubit cubit;

  setUp(() {
    repository = _MockCaptureRepository();
    cubit = CaptureCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('CaptureCubit', () {
    test('initial state is CaptureInitial', () {
      expect(cubit.state, const CaptureInitial());
    });

    test('validateImage emits validating then validated', () async {
      const report = ImageValidationReport(
        result: ValidationResult.acceptable,
        blurScore: 150.0,
        brightnessScore: 128.0,
      );
      when(() => repository.validateImage('test.jpg'))
          .thenAnswer((_) async => report);

      final expectedStates = [
        const CaptureValidating(),
        CaptureValidated(imagePath: 'test.jpg', report: report),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.validateImage('test.jpg');
    });

    test('validateImage emits CaptureError on failure', () async {
      when(() => repository.validateImage('test.jpg'))
          .thenThrow(Exception('Error'));

      final expectedStates = [
        const CaptureValidating(),
        const CaptureError('Error al analizar la imagen.'),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.validateImage('test.jpg');
    });

    test('classifyImage emits classifying then classified', () async {
      const report = ImageValidationReport(
        result: ValidationResult.acceptable,
        blurScore: 150.0,
        brightnessScore: 128.0,
      );
      final result = ClassificationResult(
        classKey: 'healthy',
        confidence: 0.95,
        allScores: {'healthy': 0.95, 'downy_mildew': 0.03, 'leaf_curl': 0.02},
      );

      when(() => repository.classifyImage('test.jpg'))
          .thenAnswer((_) async => result);

      final expectedStates = [
        const CaptureClassifying(),
        CaptureClassified(
          imagePath: 'test.jpg',
          result: result,
          validationReport: report,
        ),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.classifyImage('test.jpg', report);
    });

    test('classifyImage emits CaptureError on model failure', () async {
      const report = ImageValidationReport(
        result: ValidationResult.acceptable,
        blurScore: 150.0,
        brightnessScore: 128.0,
      );

      when(() => repository.classifyImage('test.jpg'))
          .thenThrow(StateError('Modelo no cargado'));

      final expectedStates = [
        const CaptureClassifying(),
        const CaptureError('Error al clasificar la imagen: '
            'Bad state: Modelo no cargado'),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.classifyImage('test.jpg', report);
    });

    test('saveImage emits saving then saved', () async {
      const report = ImageValidationReport(
        result: ValidationResult.acceptable,
        blurScore: 150.0,
        brightnessScore: 128.0,
      );

      when(() => repository.saveImage(
            sourcePath: any(named: 'sourcePath'),
            validationReport: any(named: 'validationReport'),
          )).thenAnswer((_) async => const SaveResult.success('img_123'));

      final expectedStates = [
        const CaptureSaving(),
        const CaptureSaved('img_123'),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder(expectedStates),
      );

      await cubit.saveImage('test.jpg', report);
    });

    test('reset returns to CaptureInitial', () {
      cubit.reset();
      expect(cubit.state, const CaptureInitial());
    });
  });
}
