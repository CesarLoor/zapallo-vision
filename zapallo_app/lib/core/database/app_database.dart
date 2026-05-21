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

  /// Cuenta el total de imágenes
  Future<int> countImages() async {
    final count = leafImages.id.count();
    final query = selectOnly(leafImages)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zapallo_ai.db'));
    return NativeDatabase.createInBackground(file);
  });
}
