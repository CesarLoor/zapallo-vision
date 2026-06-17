import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/disease_info.dart';
import '../../config/routes.dart';
import '../../core/database/app_database.dart';
import '../../core/repositories/gallery_repository.dart';
import '../../core/di/service_locator.dart';
import 'cubit/gallery_cubit.dart';
import 'cubit/gallery_state.dart';

/// Galería de imágenes guardadas — FUN-009
/// v1.5: Badges de diagnóstico en tarjetas + animaciones staggered
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<GalleryRepository>();
    return BlocProvider(
      create: (_) => GalleryCubit(repository: repo)..loadImages()..watchImages(),
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
                    color: Colors.white.withValues(alpha: 0.75),
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
    final cubit = context.read<GalleryCubit>();
    final state = context.watch<GalleryCubit>().state;
    final hasMore = state is GalleryLoaded && state.hasMore;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 300 &&
            hasMore) {
          cubit.loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: images.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= images.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _AnimatedImageCard(
            image: images[index],
            cubit: cubit,
            index: index,
          );
        },
      ),
    );
  }
}

/// Tarjeta de imagen con animación staggered de entrada
class _AnimatedImageCard extends StatefulWidget {
  final LeafImage image;
  final GalleryCubit cubit;
  final int index;

  const _AnimatedImageCard({
    required this.image,
    required this.cubit,
    required this.index,
  });

  @override
  State<_AnimatedImageCard> createState() => _AnimatedImageCardState();
}

class _AnimatedImageCardState extends State<_AnimatedImageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay based on index (cap at 8 to avoid long waits)
    final delay = Duration(milliseconds: (widget.index % 8) * 60);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _ImageCard(image: widget.image, cubit: widget.cubit),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final LeafImage image;
  final GalleryCubit cubit;
  final _dateFormat = DateFormat('dd/MM/yyyy');

  _ImageCard({required this.image, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final file = File(image.filePath);
    final hasDiagnosis = image.diagnosisClass != null;
    final disease = hasDiagnosis
        ? DiseaseDatabase.getOrDefault(image.diagnosisClass!)
        : null;

    return GestureDetector(
      key: Key('img_card_${image.id}'),
      onTap: () => context.push(
        AppRouter.imageDetail.replaceFirst(':id', image.id),
        extra: cubit,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura con badge overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ZapalloTheme.background,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: ZapalloTheme.textHint,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Badge de diagnóstico en esquina superior derecha
                  if (hasDiagnosis && disease != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: disease.color.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: disease.color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              disease.isHealthy
                                  ? Icons.check_circle_rounded
                                  : disease.icon,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                disease.isHealthy ? 'Sana' : _shortLabel(disease.labelEs),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Indicador de severidad en esquina inferior izquierda
                  if (hasDiagnosis && disease != null && !disease.isHealthy)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: DiseaseInfo.severityColor(
                                    disease.severity),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              disease.severityLabel,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Fecha, hora y confianza
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateFormat.format(image.capturedAt),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: ZapalloTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (hasDiagnosis) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            disease!.labelEs,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: disease.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${((image.diagnosisConfidence ?? 0) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: disease.color.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Mini confidence bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: image.diagnosisConfidence ?? 0,
                        minHeight: 3,
                        backgroundColor:
                            disease.color.withValues(alpha: 0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(disease.color),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Acorta etiquetas largas para el badge
  String _shortLabel(String label) {
    if (label.length <= 12) return label;
    return '${label.substring(0, 10)}…';
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
