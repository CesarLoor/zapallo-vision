import 'package:equatable/equatable.dart';
import '../../../core/services/image_validator.dart';
import '../../../core/services/classifier_service.dart';

abstract class CaptureState extends Equatable {
  const CaptureState();
  @override
  List<Object?> get props => [];
}

class CaptureInitial extends CaptureState {
  const CaptureInitial();
}

class CaptureValidating extends CaptureState {
  const CaptureValidating();
}

class CaptureValidated extends CaptureState {
  final String imagePath;
  final ImageValidationReport report;
  const CaptureValidated({required this.imagePath, required this.report});
  @override
  List<Object?> get props => [imagePath, report];
}

class CaptureSaving extends CaptureState {
  const CaptureSaving();
}

class CaptureSaved extends CaptureState {
  final String imageId;
  const CaptureSaved(this.imageId);
  @override
  List<Object?> get props => [imageId];
}

class CaptureError extends CaptureState {
  final String message;
  const CaptureError(this.message);
  @override
  List<Object?> get props => [message];
}

class CaptureClassifying extends CaptureState {
  const CaptureClassifying();
}

class CaptureClassified extends CaptureState {
  final String imagePath;
  final ClassificationResult result;
  final ImageValidationReport validationReport;
  const CaptureClassified({required this.imagePath, required this.result, required this.validationReport});
  @override
  List<Object?> get props => [imagePath, result, validationReport];
}
