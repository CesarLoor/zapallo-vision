import '../database/app_database.dart';
import '../services/storage_service.dart';

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
}
