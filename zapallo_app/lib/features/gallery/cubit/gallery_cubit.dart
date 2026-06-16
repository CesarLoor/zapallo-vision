import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/gallery_repository.dart';
import '../../../core/database/app_database.dart';
import 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  final GalleryRepository _repository;
  StreamSubscription<List<LeafImage>>? _imagesSubscription;
  static const int _pageSize = 20;

  GalleryCubit({required GalleryRepository repository})
      : _repository = repository,
        super(const GalleryLoading());

  Future<void> loadImages() async {
    emit(const GalleryLoading());
    try {
      final count = await _repository.countImages();
      final images = await _repository.getImagesPage(limit: _pageSize, offset: 0);
      emit(GalleryLoaded(images, totalCount: count));
    } catch (e) {
      emit(const GalleryError('Error al cargar las imágenes.'));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! GalleryLoaded) return;
    if (!current.hasMore) return;

    try {
      final moreImages = await _repository.getImagesPage(
        limit: _pageSize,
        offset: current.images.length,
      );
      emit(GalleryLoaded(
        [...current.images, ...moreImages],
        totalCount: current.totalCount,
      ));
    } catch (_) {}
  }

  void watchImages() {
    _imagesSubscription?.cancel();
    _imagesSubscription = _repository.watchAllImages().listen(
      (images) {
        if (!isClosed) {
          emit(GalleryLoaded(images, totalCount: images.length));
        }
      },
      onError: (_) {
        if (!isClosed) {
          emit(const GalleryError('Error al cargar las imágenes.'));
        }
      },
    );
  }

  Future<bool> deleteImage(LeafImage image) async {
    emit(const GalleryDeleting());
    final success = await _repository.deleteImage(image);
    if (success) {
      emit(const GalleryDeleted());
      await loadImages();
    } else {
      await loadImages();
    }
    return success;
  }

  @override
  Future<void> close() async {
    await _imagesSubscription?.cancel();
    return super.close();
  }
}
