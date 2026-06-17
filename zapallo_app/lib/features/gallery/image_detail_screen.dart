import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/disease_info.dart';
import '../../core/database/app_database.dart';
import '../../core/repositories/gallery_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/widgets/shared_diagnosis_widgets.dart';
import 'cubit/gallery_cubit.dart';

/// Pantalla de detalle de imagen guardada — HU-009, HU-010
/// v1.5: Ahora muestra el reporte completo de diagnóstico con tabs
class ImageDetailScreen extends StatelessWidget {
  final String imageId;
  final GalleryCubit? cubit;

  const ImageDetailScreen({super.key, required this.imageId, this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _ImageDetailView(imageId: imageId),
      );
    }
    final repo = sl<GalleryRepository>();
    return BlocProvider(
      create: (_) => GalleryCubit(repository: repo)..loadImages()..watchImages(),
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

class _ImageDetailViewState extends State<_ImageDetailView>
    with SingleTickerProviderStateMixin {
  LeafImage? _image;
  bool _loading = true;
  final _dateFormat = DateFormat('dd/MM/yyyy  HH:mm:ss');
  late final TabController _tabController;

  bool get _hasDiagnosis => _image?.diagnosisClass != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadImage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final repo = sl<GalleryRepository>();
    final image = await repo.getImageById(widget.imageId);
    if (mounted) {
      setState(() {
        _image = image;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<GalleryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

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
      HapticFeedback.mediumImpact();
      final success = await cubit.deleteImage(_image!);
      if (mounted) {
        if (success) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text(AppConstants.msgImageDeleted),
              backgroundColor: ZapalloTheme.primary,
            ),
          );
          router.pop();
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppConstants.msgDeleteError),
              backgroundColor: ZapalloTheme.error,
            ),
          );
        }
      }
    }
  }

  void _shareDiagnosis() {
    final image = _image;
    if (image == null || image.diagnosisClass == null) return;

    final info = DiseaseDatabase.getOrDefault(image.diagnosisClass!);
    final conf = ((image.diagnosisConfidence ?? 0) * 100).toStringAsFixed(1);
    final date = _dateFormat.format(image.capturedAt);

    final text = StringBuffer()
      ..writeln('DIAGNOSTICO ZAPALLOAI')
      ..writeln('=' * 35)
      ..writeln()
      ..writeln('Fecha:      $date')
      ..writeln('Enfermedad: ${info.labelEs}')
      ..writeln('Confianza:  $conf%')
      ..writeln('Severidad:  ${info.severityLabel}')
      ..writeln()
      ..writeln('-' * 35)
      ..writeln('DESCRIPCION')
      ..writeln('-' * 35)
      ..writeln(info.description)
      ..writeln();

    if (info.symptoms.isNotEmpty) {
      text.writeln('-' * 35);
      text.writeln(info.isHealthy ? 'CARACTERISTICAS' : 'SINTOMAS');
      text.writeln('-' * 35);
      for (final s in info.symptoms) {
        text.writeln('  * $s');
      }
      text.writeln();
    }

    if (info.recommendations.isNotEmpty) {
      text.writeln('-' * 35);
      text.writeln('RECOMENDACIONES');
      text.writeln('-' * 35);
      for (var i = 0; i < info.recommendations.length; i++) {
        text.writeln('  ${i + 1}. ${info.recommendations[i]}');
      }
      text.writeln();
    }

    text.writeln('=' * 35);
    text.writeln('Generado por ZapalloAI v${AppConstants.appVersion}');

    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnóstico copiado al portapapeles'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      backgroundColor: ZapalloTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, image, file),
          if (_hasDiagnosis)
            _buildDiagnosisHeader(image),
          if (_hasDiagnosis)
            _buildTabBar(),
        ],
        body: _hasDiagnosis
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildReportTab(image),
                  _buildDetailsTab(image),
                ],
              )
            : _buildDetailsTab(image),
      ),
    );
  }

  // ── SliverAppBar con imagen ─────────────────────────────────────
  SliverAppBar _buildSliverAppBar(
      BuildContext context, LeafImage image, File file) {
    final disease = _hasDiagnosis
        ? DiseaseDatabase.getOrDefault(image.diagnosisClass!)
        : null;

    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.42,
      pinned: true,
      backgroundColor: disease?.color ?? ZapalloTheme.primary,
      leading: IconButton(
        key: const Key('btn_back_detail'),
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_hasDiagnosis)
          IconButton(
            key: const Key('btn_share_image'),
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: _shareDiagnosis,
            tooltip: 'Compartir diagnóstico',
          ),
        IconButton(
          key: const Key('btn_delete_image'),
          icon:
              const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () => _confirmDelete(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              child: Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white54, size: 80),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    (disease?.color ?? Colors.black).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // Badge de resultado
            if (disease != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(disease.icon,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            disease.labelEs,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${((image.diagnosisConfidence ?? 0) * 100).toStringAsFixed(1)}% de confianza',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header del diagnóstico (título de sección) ──────────────────
  SliverToBoxAdapter _buildDiagnosisHeader(LeafImage image) {
    return SliverToBoxAdapter(
      child: Container(
        color: ZapalloTheme.background,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Icon(Icons.assignment_rounded,
                size: 22, color: ZapalloTheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Diagnóstico guardado',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZapalloTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ZapalloTheme.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dateFormat.format(image.capturedAt),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ZapalloTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TabBar ──────────────────────────────────────────────────────
  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: ZapalloTheme.primary,
          unselectedLabelColor: ZapalloTheme.textHint,
          indicatorColor: ZapalloTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_rounded, size: 20),
              text: 'Reporte',
            ),
            Tab(
              icon: Icon(Icons.info_outline_rounded, size: 20),
              text: 'Detalles',
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Reporte de diagnóstico completo ─────────────────────
  Widget _buildReportTab(LeafImage image) {
    final disease = DiseaseDatabase.getOrDefault(image.diagnosisClass!);
    final confidence = image.diagnosisConfidence ?? 0;
    final isLowConf = confidence < AppConstants.minConfidenceThreshold;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reutilizar el widget compartido de reporte completo
          DiagnosisReportSection(
            disease: disease,
            confidence: confidence,
            isLowConfidence: isLowConf,
            animate: false,
          ),
          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('btn_share_report'),
                  onPressed: _shareDiagnosis,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copiar reporte'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('btn_delete_bottom'),
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZapalloTheme.error,
                    side: const BorderSide(color: ZapalloTheme.error),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Tab 2: Detalles técnicos / metadatos ───────────────────────
  Widget _buildDetailsTab(LeafImage image) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la captura
          SectionCard(
            title: 'Información de la captura',
            icon: Icons.photo_camera_rounded,
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Fecha de captura',
                  value: _dateFormat.format(image.capturedAt),
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Identificador',
                  value: image.id.substring(0, 8).toUpperCase(),
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.photo_size_select_actual_rounded,
                  label: 'Tamaño del archivo',
                  value: _formatFileSize(image.fileSize),
                ),
                if (image.width > 0 && image.height > 0) ...[
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.aspect_ratio_rounded,
                    label: 'Resolución',
                    value: '${image.width} × ${image.height} px',
                  ),
                ],
                if (image.blurScore != null) ...[
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.blur_circular_rounded,
                    label: 'Nitidez',
                    value: _formatBlur(image.blurScore!),
                    valueColor: _blurColor(image.blurScore!),
                  ),
                ],
                if (image.brightnessScore != null) ...[
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.brightness_6_rounded,
                    label: 'Brillo',
                    value: _formatBrightness(image.brightnessScore!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Resultado de clasificación (resumen)
          if (_hasDiagnosis)
            SectionCard(
              title: 'Resultado de clasificación',
              icon: Icons.analytics_rounded,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.local_florist_rounded,
                    label: 'Clase detectada',
                    value: image.diagnosisLabel ?? 'Desconocida',
                    valueColor: DiseaseDatabase.getOrDefault(
                            image.diagnosisClass!)
                        .color,
                  ),
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.percent_rounded,
                    label: 'Confianza',
                    value:
                        '${((image.diagnosisConfidence ?? 0) * 100).toStringAsFixed(1)}%',
                  ),
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.speed_rounded,
                    label: 'Severidad',
                    value: DiseaseDatabase.getOrDefault(
                            image.diagnosisClass!)
                        .severityLabel,
                    valueColor: DiseaseInfo.severityColor(
                        DiseaseDatabase.getOrDefault(
                                image.diagnosisClass!)
                            .severity),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          if (!_hasDiagnosis) ...[
            // Botón eliminar (cuando no hay tabs)
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
            const SizedBox(height: 32),
          ],
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

  String _formatBrightness(double score) {
    if (score < AppConstants.brightnessMin) return 'Oscura (${score.toStringAsFixed(0)})';
    if (score > AppConstants.brightnessMax) return 'Sobreexpuesta (${score.toStringAsFixed(0)})';
    return 'Normal (${score.toStringAsFixed(0)})';
  }
}

// ── Delegado de TabBar persistente ───────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ZapalloTheme.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ── Widget InfoRow reutilizable ──────────────────────────────────

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
