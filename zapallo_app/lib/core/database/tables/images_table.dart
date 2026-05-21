import 'package:drift/drift.dart';

/// Tabla SQLite para imágenes de hojas capturadas
/// Cumple FUN-007 (ID único), FUN-008 (fecha/hora)
class LeafImages extends Table {
  /// Identificador único (UUID v4) — FUN-007
  TextColumn get id => text()();

  /// Ruta absoluta del archivo en el dispositivo
  TextColumn get filePath => text()();

  /// Fecha y hora de captura — FUN-008
  DateTimeColumn get capturedAt => dateTime()();

  /// Tamaño del archivo en bytes
  IntColumn get fileSize => integer().withDefault(const Constant(0))();

  /// Ancho en píxeles
  IntColumn get width => integer().withDefault(const Constant(0))();

  /// Altura en píxeles
  IntColumn get height => integer().withDefault(const Constant(0))();

  /// Puntuación de nitidez (varianza del Laplaciano)
  /// Null si no se evaluó
  RealColumn get blurScore => real().nullable()();

  /// Puntuación de brillo promedio (0-255)
  RealColumn get brightnessScore => real().nullable()();

  /// Notas del usuario (para uso futuro)
  TextColumn get notes => text().nullable()();

  // ── Campos V2.0 (diagnóstico) ─────────────────────────────────
  /// Clase detectada por el modelo (ej: 'downy_mildew')
  TextColumn get diagnosisClass => text().nullable()();

  /// Nombre en español de la enfermedad
  TextColumn get diagnosisLabel => text().nullable()();

  /// Confianza del modelo (0.0 - 1.0)
  RealColumn get diagnosisConfidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
