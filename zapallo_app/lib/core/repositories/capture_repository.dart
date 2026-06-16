import '../services/image_validator.dart';
import '../services/storage_service.dart';
import '../services/classifier_service.dart';

class CaptureRepository {
  final ImageValidator _validator;
  final StorageService _storage;
  final ClassifierService _classifier;

  CaptureRepository(this._validator, this._storage, this._classifier);

  Future<ImageValidationReport> validateImage(String imagePath) =>
      _validator.validate(imagePath);

  Future<ClassificationResult> classifyImage(String imagePath) =>
      _classifier.classify(imagePath);

  Future<SaveResult> saveImage({
    required String sourcePath,
    ImageValidationReport? validationReport,
    String? diagnosisClass,
    String? diagnosisLabel,
    double? diagnosisConfidence,
  }) =>
      _storage.saveImage(
        sourcePath: sourcePath,
        validationReport: validationReport,
        diagnosisClass: diagnosisClass,
        diagnosisLabel: diagnosisLabel,
        diagnosisConfidence: diagnosisConfidence,
      );
}
