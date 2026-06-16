import 'package:equatable/equatable.dart';
import 'package:zapallo_app/core/database/app_database.dart';

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
  final int totalCount;
  const GalleryLoaded(this.images, {this.totalCount = 0});
  @override
  List<Object?> get props => [images, totalCount];
  bool get isEmpty => images.isEmpty;
  bool get hasMore => images.length < totalCount;
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
