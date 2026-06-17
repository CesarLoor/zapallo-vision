import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'tables/images_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LeafImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor para tests: usa base de datos en memoria
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  // ── Queries ─────────────────────────────────────────────────────

  /// Obtiene todas las imágenes ordenadas por fecha de captura (más recientes primero)
  Future<List<LeafImage>> getAllImages() =>
      (select(leafImages)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
          .get();

  /// Stream reactivo para la galería
  Stream<List<LeafImage>> watchAllImages() =>
      (select(leafImages)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
          .watch();

  /// Obtiene una imagen por ID
  Future<LeafImage?> getImageById(String id) =>
      (select(leafImages)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Inserta una nueva imagen
  Future<void> insertImage(LeafImagesCompanion image) =>
      into(leafImages).insert(image);

  /// Elimina una imagen por ID
  Future<int> deleteImage(String id) =>
      (delete(leafImages)..where((t) => t.id.equals(id))).go();

  /// Obtiene imágenes paginadas
  Future<List<LeafImage>> getImagesPage({int limit = 20, int offset = 0}) =>
      (select(leafImages)
            ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
            ..limit(limit, offset: offset))
          .get();

  /// Cuenta el total de imágenes
  Future<int> countImages() async {
    final count = leafImages.id.count();
    final query = selectOnly(leafImages)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Cuenta imágenes con diagnóstico 'healthy'
  Future<int> countHealthyImages() async {
    final count = leafImages.id.count();
    final query = selectOnly(leafImages)
      ..addColumns([count])
      ..where(leafImages.diagnosisClass.equals('healthy'));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Cuenta imágenes con diagnóstico de enfermedad (no healthy, no null)
  Future<int> countDiseasedImages() async {
    final count = leafImages.id.count();
    final query = selectOnly(leafImages)
      ..addColumns([count])
      ..where(leafImages.diagnosisClass.isNotNull() &
          leafImages.diagnosisClass.equals('healthy').not());
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Obtiene la imagen más reciente con diagnóstico
  Future<LeafImage?> getLastDiagnosedImage() =>
      (select(leafImages)
            ..where((t) => t.diagnosisClass.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
            ..limit(1))
          .getSingleOrNull();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zapallo_ai.db'));
    return NativeDatabase.createInBackground(file);
  });
}
