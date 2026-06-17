import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../config/theme.dart';
import '../../config/disease_info.dart';
import '../../config/routes.dart';
import '../../core/repositories/gallery_repository.dart';
import '../../core/di/service_locator.dart';

/// Pantalla principal — punto de entrada de la app.
/// Cumple RNF-001: flujo de max 3 pasos (Home → Cámara → Guardar)
/// v1.5: Mini dashboard de estadísticas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DiagnosisStats? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final repo = sl<GalleryRepository>();
      final stats = await repo.getStatistics();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar estadísticas cada vez que el home se muestre
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final clf = ClassifierProvider.of(context);
    final modelReady = clf.isReady;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZapalloTheme.heroGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // ── Header ────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Column(
                            children: [
                              // Logo / ícono de la app
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ZapalloAI',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Detector de enfermedades foliares\nen plantas de zapallo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.80),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Mini Dashboard de estadísticas ────────────
                        if (!_loadingStats && _stats != null && _stats!.totalImages > 0)
                          _StatsDashboard(stats: _stats!),

                        const Spacer(),

                        // Banner si el modelo no cargó (degraded mode)
                        if (!modelReady)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: ZapalloTheme.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ZapalloTheme.warning.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: ZapalloTheme.warning, size: 18),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Modelo de IA no disponible. La clasificación no funcionará.',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: ZapalloTheme.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ── Tarjeta de acciones ──────────────────────
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chip de estado offline
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: ZapalloTheme.primarySurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: ZapalloTheme.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Modo offline — sin internet',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: ZapalloTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Botón principal: Capturar imagen
                              _HomeActionButton(
                                id: 'btn_capture',
                                icon: Icons.camera_alt_rounded,
                                label: 'Capturar imagen',
                                subtitle: 'Fotografía una hoja de zapallo',
                                isPrimary: true,
                                onTap: () => context.push(AppRouter.capture),
                              ),

                              const SizedBox(height: 12),

                              // Botón secundario: Ver galería
                              _HomeActionButton(
                                id: 'btn_gallery',
                                icon: Icons.photo_library_rounded,
                                label: 'Ver imágenes guardadas',
                                subtitle: _stats != null && _stats!.totalImages > 0
                                    ? '${_stats!.totalImages} ${_stats!.totalImages == 1 ? 'imagen' : 'imágenes'} en galería'
                                    : 'Galería local de capturas',
                                isPrimary: false,
                                onTap: () async {
                                  await context.push(AppRouter.gallery);
                                  // Recargar stats al volver de la galería
                                  _loadStats();
                                },
                              ),

                              const SizedBox(height: 20),

                              // Nota de privacidad
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: ZapalloTheme.textHint,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tus imágenes nunca se envían a internet',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      color: ZapalloTheme.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Universidad
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'ESPE · Tesis de Grado 2026',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Mini dashboard de estadísticas en el home
class _StatsDashboard extends StatelessWidget {
  final DiagnosisStats stats;
  const _StatsDashboard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final lastDate = stats.lastDiagnosed != null
        ? DateFormat('dd/MM/yyyy').format(stats.lastDiagnosed!.capturedAt)
        : null;
    final lastDisease = stats.lastDiagnosed?.diagnosisClass != null
        ? DiseaseDatabase.getOrDefault(stats.lastDiagnosed!.diagnosisClass!)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded,
                  size: 16, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                'Resumen de análisis',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                icon: Icons.photo_library_outlined,
                value: '${stats.totalImages}',
                label: 'Total',
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.check_circle_outline_rounded,
                value: '${stats.healthyCount}',
                label: 'Sanas',
                color: const Color(0xFF52B788),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.warning_amber_rounded,
                value: '${stats.diseasedCount}',
                label: 'Enfermas',
                color: const Color(0xFFE76F51),
              ),
            ],
          ),
          if (lastDisease != null && lastDate != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Último: ${lastDisease.labelEs} · $lastDate',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip de estadística individual
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de acción en el home
class _HomeActionButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _HomeActionButton({
    required this.id,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? ZapalloTheme.primary : ZapalloTheme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key(id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : ZapalloTheme.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : ZapalloTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary
                            ? Colors.white
                            : ZapalloTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.75)
                            : ZapalloTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : ZapalloTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
