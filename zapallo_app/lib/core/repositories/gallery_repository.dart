import '../database/app_database.dart';
import '../services/storage_service.dart';

/// Estadísticas de diagnóstico para el dashboard del home
class DiagnosisStats {
  final int totalImages;
  final int healthyCount;
  final int diseasedCount;
  final LeafImage? lastDiagnosed;

  const DiagnosisStats({
    required this.totalImages,
    required this.healthyCount,
    required this.diseasedCount,
    this.lastDiagnosed,
  });
}

class GalleryRepository {
  final AppDatabase _db;
  final StorageService _storage;

  GalleryRepository(this._db, this._storage);

  Future<List<LeafImage>> getAllImages() => _db.getAllImages();

  Future<List<LeafImage>> getImagesPage({int limit = 20, int offset = 0}) =>
      _db.getImagesPage(limit: limit, offset: offset);

  Future<int> countImages() => _db.countImages();

  Stream<List<LeafImage>> watchAllImages() => _db.watchAllImages();

  Future<bool> deleteImage(LeafImage image) => _storage.deleteImage(image);

  Future<LeafImage?> getImageById(String id) => _db.getImageById(id);

  /// Obtiene estadísticas de diagnóstico para el dashboard
  Future<DiagnosisStats> getStatistics() async {
    final results = await Future.wait([
      _db.countImages(),
      _db.countHealthyImages(),
      _db.countDiseasedImages(),
      _db.getLastDiagnosedImage(),
    ]);
    return DiagnosisStats(
      totalImages: results[0] as int,
      healthyCount: results[1] as int,
      diseasedCount: results[2] as int,
      lastDiagnosed: results[3] as LeafImage?,
    );
  }
}
