import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/disease_info.dart';
import '../../config/routes.dart';
import '../../core/services/classifier_service.dart';
import '../../core/services/image_validator.dart';
import '../../core/repositories/capture_repository.dart';
import '../../core/di/service_locator.dart';

/// Pantalla de resultados del diagnóstico — HU-006, HU-007
/// Muestra la enfermedad detectada, confianza, síntomas y recomendaciones.
class DiagnosisScreen extends StatefulWidget {
  final String imagePath;
  final ClassificationResult result;
  final ImageValidationReport? validationReport;

  const DiagnosisScreen({
    super.key,
    required this.imagePath,
    required this.result,
    this.validationReport,
  });

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;
  bool _isSaving = false;
  bool _saved = false;
  bool _autoSaved = false;

  DiseaseInfo get _disease =>
      DiseaseDatabase.getOrDefault(widget.result.classKey);

  bool get _isLowConfidence =>
      widget.result.confidence < AppConstants.minConfidenceThreshold;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();

    // Auto-guardado silencioso al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _save(isAuto: true);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _save({bool isAuto = false}) async {
    if (_isSaving || _saved) return;
    setState(() => _isSaving = true);

    try {
      final repo = sl<CaptureRepository>();
      final saveResult = await repo.saveImage(
        sourcePath: widget.imagePath,
        validationReport: widget.validationReport,
        diagnosisClass: widget.result.classKey,
        diagnosisLabel: _disease.labelEs,
        diagnosisConfidence: widget.result.confidence,
      );

      if (!mounted) return;

      if (saveResult.success) {
        if (isAuto) {
          HapticFeedback.lightImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
        setState(() {
          _saved = true;
          _autoSaved = isAuto;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAuto ? AppConstants.msgAutoSaved : 'Resultado guardado correctamente'),
            duration: Duration(seconds: isAuto ? 2 : 3),
            backgroundColor: ZapalloTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveResult.errorMessage ?? 'Error al guardar'),
            backgroundColor: ZapalloTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = widget.result.confidence;
    final pct = (confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: ZapalloTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con imagen ─────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.35,
            pinned: true,
            backgroundColor: _disease.color,
            leading: IconButton(
              key: const Key('btn_back_diagnosis'),
              icon:
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.go(AppRouter.home),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                  // Overlay con gradiente
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          _disease.color.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Badge de resultado
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(_disease.icon,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _disease.labelEs,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$pct% de confianza',
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
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: Opacity(opacity: _fadeIn.value, child: child),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Banner de baja confianza ────────────────
                    if (_isLowConfidence) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ZapalloTheme.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ZapalloTheme.warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: ZapalloTheme.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppConstants.msgLowConfidence,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: ZapalloTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Barra de confianza ─────────────────────────
                    _ConfidenceBar(
                      confidence: confidence,
                      color: _disease.color,
                    ),
                    const SizedBox(height: 20),

                    // ── Badge de severidad ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: DiseaseInfo.severityColor(_disease.severity)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DiseaseInfo.severityColor(_disease.severity)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: DiseaseInfo.severityColor(
                                  _disease.severity),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _disease.severityLabel,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DiseaseInfo.severityColor(
                                  _disease.severity),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Descripción ────────────────────────────────
                    _SectionCard(
                      title: 'Descripción',
                      icon: Icons.info_outline_rounded,
                      child: Text(
                        _disease.description,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: ZapalloTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Síntomas ───────────────────────────────────
                    if (_disease.symptoms.isNotEmpty)
                      _SectionCard(
                        title: _disease.isHealthy
                            ? 'Características'
                            : 'Síntomas',
                        icon: _disease.isHealthy
                            ? Icons.check_circle_outline_rounded
                            : Icons.local_hospital_rounded,
                        child: Column(
                          children: _disease.symptoms
                              .map((s) => _BulletItem(text: s))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // ── Recomendaciones ────────────────────────────
                    if (_disease.recommendations.isNotEmpty)
                      _SectionCard(
                        title: 'Recomendaciones',
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: ZapalloTheme.secondary,
                        child: Column(
                          children: _disease.recommendations
                              .asMap()
                              .entries
                              .map((e) => _NumberedItem(
                                  number: e.key + 1, text: e.value))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // ── Todas las clases (scores) ──────────────────
                    _SectionCard(
                      title: 'Detalle de clasificación',
                      icon: Icons.bar_chart_rounded,
                      child: Column(
                        children: () {
                          final entries = widget.result.allScores.entries.toList();
                          entries.sort((a, b) => b.value.compareTo(a.value));
                          return entries.map((e) {
                            final info = DiseaseDatabase.getOrDefault(e.key);
                            return _ScoreRow(
                              label: info.labelEs,
                              score: e.value,
                              isTop: e.key == widget.result.classKey,
                              color: info.color,
                            );
                          }).toList();
                        }(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botones ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('btn_new_capture'),
                            onPressed: () => context.go(AppRouter.capture),
                            icon: const Icon(Icons.camera_alt_rounded,
                                size: 20),
                            label: const Text('Nueva captura'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            key: const Key('btn_save_diagnosis'),
                            onPressed:
                                _saved || _isSaving ? null : () => _save(),
                            icon: Icon(
                              _saved
                                  ? Icons.check_rounded
                                  : Icons.save_alt_rounded,
                              size: 20,
                            ),
                            label: Text(_saved
                                ? (_autoSaved ? 'Auto-guardado' : 'Guardado')
                                : _isSaving
                                    ? 'Guardando...'
                                    : 'Guardar resultado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _saved
                                  ? ZapalloTheme.success
                                  : ZapalloTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────

class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  final Color color;
  const _ConfidenceBar({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nivel de confianza',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: ZapalloTheme.textSecondary,
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20, color: iconColor ?? ZapalloTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ZapalloTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: ZapalloTheme.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: ZapalloTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  final int number;
  final String text;
  const _NumberedItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: ZapalloTheme.primarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ZapalloTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: ZapalloTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;
  final bool isTop;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.score,
    required this.isTop,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isTop ? color : color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: isTop ? FontWeight.w600 : FontWeight.w400,
                color: isTop
                    ? ZapalloTheme.textPrimary
                    : ZapalloTheme.textSecondary,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: isTop ? FontWeight.w700 : FontWeight.w400,
              color: isTop ? color : ZapalloTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
