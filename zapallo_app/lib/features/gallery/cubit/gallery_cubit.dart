import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/storage_service.dart';
import 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  final AppDatabase _db;
  final StorageService _storage;

  GalleryCubit({required AppDatabase db, required StorageService storage})
      : _db = db,
        _storage = storage,
        super(const GalleryLoading());

  /// Carga todas las imágenes — FUN-009
  Future<void> loadImages() async {
    emit(const GalleryLoading());
    try {
      final images = await _db.getAllImages();
      emit(GalleryLoaded(images));
    } catch (e) {
      emit(const GalleryError('Error al cargar las imágenes.'));
    }
  }

  /// Elimina una imagen — FUN-011
  Future<bool> deleteImage(LeafImage image) async {
    emit(const GalleryDeleting());
    final success = await _storage.deleteImage(image);
    if (success) {
      emit(const GalleryDeleted());
      await loadImages(); // Recargar lista actualizada
    } else {
      await loadImages();
    }
    return success;
  }
}
