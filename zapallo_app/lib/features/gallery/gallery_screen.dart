import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../core/database/app_database.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart';
import 'cubit/gallery_cubit.dart';
import 'cubit/gallery_state.dart';

/// Galería de imágenes guardadas — FUN-009
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GalleryCubit(
        db: db,
        storage: StorageService(db),
      )..loadImages(),
      child: const _GalleryView(),
    );
  }
}

class _GalleryView extends StatelessWidget {
  const _GalleryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZapalloTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, innerBoxIsScrolled),
        ],
        body: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ZapalloTheme.primary),
              );
            }

            if (state is GalleryError) {
              return Center(
                child: Text(state.message,
                    style: const TextStyle(color: ZapalloTheme.textSecondary)),
              );
            }

            if (state is GalleryLoaded) {
              if (state.isEmpty) {
                return _EmptyGallery();
              }
              return _ImageGrid(images: state.images);
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_capture'),
        onPressed: () => context.push(AppRouter.capture),
        backgroundColor: ZapalloTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text(
          'Capturar',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ZapalloTheme.primary,
      leading: IconButton(
        key: const Key('btn_back_gallery'),
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            final count = state is GalleryLoaded ? state.images.length : 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis imágenes',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'imagen' : 'imágenes'} guardadas',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            );
          },
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: ZapalloTheme.primaryGradient),
        ),
      ),
    );
  }
}

/// Grid de imágenes — FUN-009
class _ImageGrid extends StatelessWidget {
  final List<LeafImage> images;
  const _ImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => _ImageCard(image: images[index]),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final LeafImage image;
  final _dateFormat = DateFormat('dd/MM/yyyy\nHH:mm');

  _ImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
    final file = File(image.filePath);

    return GestureDetector(
      key: Key('img_card_${image.id}'),
      onTap: () => context.push(
        AppRouter.imageDetail.replaceFirst(':id', image.id),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: file.existsSync()
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: ZapalloTheme.background,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: ZapalloTheme.textHint,
                          size: 40,
                        ),
                      ),
              ),
            ),
            // Fecha y hora
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                _dateFormat.format(image.capturedAt),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: ZapalloTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío de galería — HU-008 escenario 2
class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ZapalloTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: ZapalloTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin imágenes guardadas',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZapalloTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppConstants.msgNoImages,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: ZapalloTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
