import 'package:flutter/material.dart';

class DiseaseInfo {
  final String classKey;
  final String labelEs;
  final String description;
  final List<String> symptoms;
  final List<String> recommendations;
  final String severity;       // 'none', 'low', 'medium', 'high'
  final Color color;
  final IconData icon;

  const DiseaseInfo({
    required this.classKey,
    required this.labelEs,
    required this.description,
    required this.symptoms,
    required this.recommendations,
    required this.severity,
    required this.color,
    required this.icon,
  });

  /// Retorna true si la planta está sana
  bool get isHealthy => classKey == 'healthy';

  /// Color de severidad para badges
  static Color severityColor(String severity) {
    switch (severity) {
      case 'none':
        return const Color(0xFF52B788);
      case 'low':
        return const Color(0xFFE9A03B);
      case 'medium':
        return const Color(0xFFE76F51);
      case 'high':
        return const Color(0xFFD62828);
      default:
        return const Color(0xFF5C6B63);
    }
  }

  /// Etiqueta de severidad en español
  String get severityLabel {
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

/// Base de conocimiento de enfermedades del zapallo
class DiseaseDatabase {
  DiseaseDatabase._();

  static const Map<String, DiseaseInfo> _diseases = {
    'healthy': DiseaseInfo(
      classKey: 'healthy',
      labelEs: 'Hoja sana',
      description:
          'La hoja no presenta signos visibles de enfermedad ni daño por plagas. '
          'El tejido foliar muestra coloración verde uniforme y turgencia normal.',
      symptoms: [
        'Coloración verde uniforme',
        'Sin manchas ni decoloración',
        'Bordes intactos sin deformación',
        'Textura firme y turgente',
      ],
      recommendations: [
        'Mantener el riego regular y uniforme',
        'Aplicar fertilización balanceada (N-P-K)',
        'Monitorear semanalmente para detección temprana',
        'Mantener buena ventilación entre plantas',
      ],
      severity: 'none',
      color: Color(0xFF52B788),
      icon: Icons.check_circle_rounded,
    ),
    'downy_mildew': DiseaseInfo(
      classKey: 'downy_mildew',
      labelEs: 'Mildiú velloso',
      description:
          'Enfermedad fúngica causada por Pseudoperonospora cubensis. '
          'Afecta principalmente el envés de las hojas con un moho grisáceo. '
          'Se propaga rápidamente en condiciones húmedas y cálidas.',
      symptoms: [
        'Manchas amarillentas angulares en el haz',
        'Moho gris-violáceo en el envés de la hoja',
        'Las manchas se expanden y se vuelven necróticas',
        'Las hojas se secan y caen prematuramente',
      ],
      recommendations: [
        'Aplicar fungicida a base de cobre (oxicloruro de cobre)',
        'Usar fungicidas sistémicos: metalaxil o fosetil-aluminio',
        'Eliminar y destruir hojas infectadas',
        'Mejorar la ventilación entre plantas (espaciado adecuado)',
        'Evitar riego por aspersión; preferir riego por goteo',
        'Rotar cultivos: no sembrar cucurbitáceas en el mismo lote por 2-3 años',
      ],
      severity: 'high',
      color: Color(0xFFE9A03B),
      icon: Icons.warning_rounded,
    ),
    'leaf_curl': DiseaseInfo(
      classKey: 'leaf_curl',
      labelEs: 'Encrespamiento foliar',
      description:
          'Enfermedad viral transmitida por la mosca blanca (Bemisia tabaci). '
          'Causa deformación y enrollamiento de las hojas, reduciendo la fotosíntesis '
          'y afectando severamente el rendimiento del cultivo.',
      symptoms: [
        'Hojas enrolladas hacia arriba o hacia abajo',
        'Engrosamiento de las nervaduras',
        'Enanismo de la planta',
        'Deformación de hojas nuevas',
        'Reducción del tamaño de los frutos',
      ],
      recommendations: [
        'Controlar la mosca blanca con trampas amarillas pegajosas',
        'Aplicar insecticidas sistémicos (imidacloprid, tiametoxam)',
        'Usar mallas antiáfidos en semilleros',
        'Eliminar plantas severamente infectadas',
        'Sembrar barreras vivas (maíz, sorgo) alrededor del cultivo',
        'Utilizar variedades resistentes cuando estén disponibles',
      ],
      severity: 'high',
      color: Color(0xFFE76F51),
      icon: Icons.eco_rounded,
    ),
    'mosaic_virus': DiseaseInfo(
      classKey: 'mosaic_virus',
      labelEs: 'Virus del mosaico',
      description:
          'Enfermedad causada por virus como ZYMV (Zucchini Yellow Mosaic Virus) '
          'o CMV (Cucumber Mosaic Virus). Se transmite por áfidos de forma no persistente. '
          'Causa mosaicos de color en las hojas y deformación de frutos.',
      symptoms: [
        'Patrón de mosaico (manchas claras y oscuras alternas)',
        'Deformación y ampollas en la superficie foliar',
        'Hojas más pequeñas de lo normal',
        'Frutos deformes con protuberancias',
        'Reducción general del vigor de la planta',
      ],
      recommendations: [
        'Controlar áfidos vectores con insecticidas (piretroides)',
        'Eliminar inmediatamente plantas con síntomas severos',
        'Desinfectar herramientas de poda entre plantas',
        'Usar semilla certificada libre de virus',
        'Eliminar malezas hospederas alrededor del cultivo',
        'Aplicar aceite mineral para reducir transmisión por áfidos',
      ],
      severity: 'high',
      color: Color(0xFFD62828),
      icon: Icons.bug_report_rounded,
    ),
    'red_beetle': DiseaseInfo(
      classKey: 'red_beetle',
      labelEs: 'Daño por escarabajo rojo',
      description:
          'Daño causado por el escarabajo rojo de las cucurbitáceas '
          '(Aulacophora spp. / Diabrotica spp.). Los adultos se alimentan de las hojas '
          'creando agujeros irregulares, mientras las larvas dañan raíces y tallos.',
      symptoms: [
        'Agujeros irregulares en las hojas',
        'Bordes de hojas mordidos',
        'Presencia visible de escarabajos rojos/naranjas',
        'Marchitez por daño en raíces (larvas)',
        'Excrementos oscuros sobre las hojas',
      ],
      recommendations: [
        'Recoger manualmente los escarabajos adultos (control mecánico)',
        'Aplicar insecticida biológico: Beauveria bassiana',
        'Usar trampas con atrayentes (cucurbitacinas)',
        'Aplicar carbaril o permetrina en infestaciones severas',
        'Cubrir plántulas jóvenes con malla hasta que se fortalezcan',
        'Rotación de cultivos para romper ciclo de vida de larvas',
      ],
      severity: 'medium',
      color: Color(0xFFB23A1A),
      icon: Icons.pest_control_rounded,
    ),
  };

  /// Obtiene la información de una enfermedad por su clave de clase
  static DiseaseInfo? get(String classKey) => _diseases[classKey];

  /// Obtiene la información o retorna un fallback genérico
  static DiseaseInfo getOrDefault(String classKey) {
    return _diseases[classKey] ??
        DiseaseInfo(
          classKey: classKey,
          labelEs: classKey.replaceAll('_', ' '),
          description: 'Información no disponible para esta clase.',
          symptoms: [],
          recommendations: [],
          severity: 'low',
          color: const Color(0xFF5C6B63),
          icon: Icons.help_outline_rounded,
        );
  }

  /// Lista de todas las clases conocidas
  static List<String> get allClasses => _diseases.keys.toList();
}
