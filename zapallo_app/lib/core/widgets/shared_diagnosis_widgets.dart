import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/disease_info.dart';

// ── Widgets compartidos de diagnóstico ─────────────────────────────
// Extraídos de DiagnosisScreen para reutilizar en ImageDetailScreen.

/// Barra visual de nivel de confianza con animación
class ConfidenceBar extends StatelessWidget {
  final double confidence;
  final Color color;
  final bool animate;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    required this.color,
    this.animate = true,
  });

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
            child: animate
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: confidence),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : LinearProgressIndicator(
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

/// Badge de severidad con dot de color e etiqueta
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = DiseaseInfo.severityColor(severity);
    final label = _severityLabel(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'none':
        return 'Sin enfermedad';
      case 'low':
        return 'Severidad baja';
      case 'medium':
        return 'Severidad media';
      case 'high':
        return 'Severidad alta';
      default:
        return 'Desconocido';
    }
  }
}

/// Tarjeta de sección con título, icono y contenido
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const SectionCard({
    super.key,
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
              Icon(icon, size: 20, color: iconColor ?? ZapalloTheme.primary),
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

/// Item con bullet point
class BulletItem extends StatelessWidget {
  final String text;
  const BulletItem({super.key, required this.text});

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

/// Item con número
class NumberedItem extends StatelessWidget {
  final int number;
  final String text;
  const NumberedItem({super.key, required this.number, required this.text});

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

/// Banner de baja confianza
class LowConfidenceBanner extends StatelessWidget {
  final String message;
  const LowConfidenceBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              message,
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
    );
  }
}

/// Sección completa de reporte de diagnóstico reutilizable.
/// Muestra: barra de confianza, severidad, descripción, síntomas y recomendaciones.
class DiagnosisReportSection extends StatelessWidget {
  final DiseaseInfo disease;
  final double confidence;
  final bool isLowConfidence;
  final bool animate;

  const DiagnosisReportSection({
    super.key,
    required this.disease,
    required this.confidence,
    this.isLowConfidence = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de baja confianza
        if (isLowConfidence) ...[
          const LowConfidenceBanner(
            message:
                'Baja confianza en el resultado. Considere tomar otra captura con mejor iluminación.',
          ),
          const SizedBox(height: 16),
        ],

        // Barra de confianza
        ConfidenceBar(
          confidence: confidence,
          color: disease.color,
          animate: animate,
        ),
        const SizedBox(height: 16),

        // Badge de severidad
        SeverityBadge(severity: disease.severity),
        const SizedBox(height: 16),

        // Descripción
        SectionCard(
          title: 'Descripción',
          icon: Icons.info_outline_rounded,
          child: Text(
            disease.description,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: ZapalloTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Síntomas
        if (disease.symptoms.isNotEmpty)
          SectionCard(
            title: disease.isHealthy ? 'Características' : 'Síntomas',
            icon: disease.isHealthy
                ? Icons.check_circle_outline_rounded
                : Icons.local_hospital_rounded,
            child: Column(
              children:
                  disease.symptoms.map((s) => BulletItem(text: s)).toList(),
            ),
          ),
        if (disease.symptoms.isNotEmpty) const SizedBox(height: 12),

        // Recomendaciones
        if (disease.recommendations.isNotEmpty)
          SectionCard(
            title: 'Recomendaciones',
            icon: Icons.lightbulb_outline_rounded,
            iconColor: ZapalloTheme.secondary,
            child: Column(
              children: disease.recommendations
                  .asMap()
                  .entries
                  .map(
                      (e) => NumberedItem(number: e.key + 1, text: e.value))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
