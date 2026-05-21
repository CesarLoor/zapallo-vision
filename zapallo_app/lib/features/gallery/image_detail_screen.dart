import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../core/database/app_database.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart';
import 'cubit/gallery_cubit.dart';
import 'cubit/gallery_state.dart';

/// Pantalla de detalle de imagen guardada — HU-009, HU-010
class ImageDetailScreen extends StatelessWidget {
  final String imageId;

  const ImageDetailScreen({super.key, required this.imageId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GalleryCubit(
        db: db,
        storage: StorageService(db),
      )..loadImages(),
      child: _ImageDetailView(imageId: imageId),
    );
  }
}

class _ImageDetailView extends StatefulWidget {
  final String imageId;
  const _ImageDetailView({required this.imageId});

  @override
  State<_ImageDetailView> createState() => _ImageDetailViewState();
}

class _ImageDetailViewState extends State<_ImageDetailView> {
  LeafImage? _image;
  bool _loading = true;
  final _dateFormat = DateFormat('dd/MM/yyyy  HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final image = await db.getImageById(widget.imageId);
    if (mounted) {
      setState(() {
        _image = image;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar imagen?',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          AppConstants.msgDeleteConfirm,
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            key: const Key('btn_cancel_delete'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZapalloTheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && _image != null && mounted) {
      final success =
          await context.read<GalleryCubit>().deleteImage(_image!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppConstants.msgImageDeleted),
              backgroundColor: ZapalloTheme.primary,
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.msgDeleteError),
              backgroundColor: ZapalloTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_image == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Imagen')),
        body: const Center(child: Text('Imagen no encontrada.')),
      );
    }

    final image = _image!;
    final file = File(image.filePath);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con imagen ─────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.55,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              key: const Key('btn_back_detail'),
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                key: const Key('btn_delete_image'),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white),
                onPressed: () => _confirmDelete(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: file.existsSync()
                  ? InteractiveViewer(
                      child: Image.file(file, fit: BoxFit.contain),
                    )
                  : const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white54, size: 80),
                    ),
            ),
          ),

          // ── Metadatos ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: ZapalloTheme.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ZapalloTheme.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Información de la captura',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ZapalloTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fecha y hora — FUN-008
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Fecha de captura',
                    value: _dateFormat.format(image.capturedAt),
                  ),
                  const Divider(height: 24),

                  // ID — FUN-007
                  _InfoRow(
                    icon: Icons.fingerprint_rounded,
                    label: 'Identificador',
                    value: image.id.substring(0, 8).toUpperCase(),
                  ),
                  const Divider(height: 24),

                  // Tamaño
                  _InfoRow(
                    icon: Icons.photo_size_select_actual_rounded,
                    label: 'Tamaño del archivo',
                    value: _formatFileSize(image.fileSize),
                  ),

                  // Calidad (si disponible)
                  if (image.blurScore != null) ...[
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.blur_circular_rounded,
                      label: 'Nitidez',
                      value: _formatBlur(image.blurScore!),
                      valueColor: _blurColor(image.blurScore!),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botón eliminar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('btn_delete_bottom'),
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar imagen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ZapalloTheme.error,
                        side: const BorderSide(color: ZapalloTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatBlur(double score) {
    if (score > 200) return 'Excelente (${score.toStringAsFixed(0)})';
    if (score > 80) return 'Buena (${score.toStringAsFixed(0)})';
    return 'Borrosa (${score.toStringAsFixed(0)})';
  }

  Color _blurColor(double score) {
    if (score > 200) return ZapalloTheme.success;
    if (score > 80) return ZapalloTheme.secondary;
    return ZapalloTheme.error;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ZapalloTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: ZapalloTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? ZapalloTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
