import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/capture_repository.dart';
import '../../../core/services/image_validator.dart';
import 'capture_state.dart';

class CaptureCubit extends Cubit<CaptureState> {
  final CaptureRepository _repository;

  CaptureCubit({required CaptureRepository repository})
      : _repository = repository,
        super(const CaptureInitial());

  Future<void> validateImage(String imagePath) async {
    emit(const CaptureValidating());
    try {
      final report = await _repository.validateImage(imagePath);
      emit(CaptureValidated(imagePath: imagePath, report: report));
    } catch (e) {
      emit(const CaptureError('Error al analizar la imagen.'));
    }
  }

  Future<void> classifyImage(String imagePath, ImageValidationReport report) async {
    emit(const CaptureClassifying());
    try {
      final result = await _repository.classifyImage(imagePath);
      emit(CaptureClassified(
        imagePath: imagePath,
        result: result,
        validationReport: report,
      ));
    } catch (e) {
      emit(CaptureError('Error al clasificar la imagen: $e'));
    }
  }

  Future<void> saveImage(String imagePath, ImageValidationReport report) async {
    emit(const CaptureSaving());
    final result = await _repository.saveImage(
      sourcePath: imagePath,
      validationReport: report,
    );
    if (result.success) {
      emit(CaptureSaved(result.imageId!));
    } else {
      emit(CaptureError(result.errorMessage ?? 'Error al guardar.'));
    }
  }

  void reset() => emit(const CaptureInitial());
}
