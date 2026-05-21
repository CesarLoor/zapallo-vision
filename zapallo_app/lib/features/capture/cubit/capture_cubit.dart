import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/image_validator.dart';
import '../../../core/services/storage_service.dart';
import 'capture_state.dart';

class CaptureCubit extends Cubit<CaptureState> {
  final ImageValidator _validator;
  final StorageService _storage;

  CaptureCubit({
    required ImageValidator validator,
    required StorageService storage,
  })  : _validator = validator,
        _storage = storage,
        super(const CaptureInitial());

  /// Valida la imagen recién capturada — FUN-004
  Future<void> validateImage(String imagePath) async {
    emit(const CaptureValidating());
    try {
      final report = await _validator.validate(imagePath);
      emit(CaptureValidated(imagePath: imagePath, report: report));
    } catch (e) {
      emit(const CaptureError('Error al analizar la imagen.'));
    }
  }

  /// Guarda la imagen en almacenamiento local — FUN-006
  Future<void> saveImage(String imagePath, ImageValidationReport report) async {
    emit(const CaptureSaving());
    final result = await _storage.saveImage(
      sourcePath: imagePath,
      validationReport: report,
    );
    if (result.success) {
      emit(CaptureSaved(result.imageId!));
    } else {
      emit(CaptureError(result.errorMessage ?? 'Error al guardar.'));
    }
  }

  /// Reinicia el estado para nueva captura — FUN-003
  void reset() => emit(const CaptureInitial());
}
