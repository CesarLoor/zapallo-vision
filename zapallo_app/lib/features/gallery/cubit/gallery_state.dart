import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();
  @override
  List<Object?> get props => [];
}

class GalleryLoading extends GalleryState {
  const GalleryLoading();
}

class GalleryLoaded extends GalleryState {
  final List<LeafImage> images;
  const GalleryLoaded(this.images);
  @override
  List<Object?> get props => [images];
  bool get isEmpty => images.isEmpty;
}

class GalleryError extends GalleryState {
  final String message;
  const GalleryError(this.message);
  @override
  List<Object?> get props => [message];
}

class GalleryDeleting extends GalleryState {
  const GalleryDeleting();
}

class GalleryDeleted extends GalleryState {
  const GalleryDeleted();
}
