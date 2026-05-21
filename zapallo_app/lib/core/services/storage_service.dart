import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart';
import '../../config/constants.dart';
import '../database/app_database.dart';
import '../database/tables/images_table.dart';
import 'image_validator.dart';

/// Resultado del guardado de imagen
class SaveResult {
  final bool success;
  final String? imageId;
  final String? errorMessage;

  const SaveResult.success(this.imageId)
      : success = true,
        errorMessage = null;

  const SaveResult.failure(this.errorMessage)
      : success = false,
        imageId = null;
}

/// Servicio de almacenamiento local de imágenes.
///
/// Cumple FUN-006, FUN-007, FUN-008 del SRS:
/// - Guarda la imagen en el directorio de documentos de la app
/// - Asigna un UUID único y timestamp
/// - Sin envío a servidores (RNF-005)
class StorageService {
  final AppDatabase _db;
  final _uuid = const Uuid();
  final _dateFormat = DateFormat('yyyyMMdd_HHmmss');

  StorageService(this._db);

  /// Guarda la imagen desde [sourcePath] y registra los metadatos en la DB.
  /// Retorna [SaveResult] con el ID asignado o un mensaje de error.
  Future<SaveResult> saveImage({
    required String sourcePath,
    ImageValidationReport? validationReport,
  }) async {
    try {
      // 1. Crear carpeta de destino si no existe
      final destFolder = await _getImagesDirectory();

      // 2. Generar nombre único: zapallo_20260521_143022_<uuid8>.jpg
      final id = _uuid.v4();
      final shortId = id.replaceAll('-', '').substring(0, 8);
      final timestamp = _dateFormat.format(DateTime.now());
      final fileName =
          '${AppConstants.imageNamePrefix}_${timestamp}_$shortId${AppConstants.imageExtension}';
      final destPath = p.join(destFolder.path, fileName);

      // 3. Copiar archivo al destino permanente
      final sourceFile = File(sourcePath);
      await sourceFile.copy(destPath);

      // 4. Obtener información del archivo
      final destFile = File(destPath);
      final fileSize = await destFile.length();

      // 5. Registrar en base de datos
      await _db.insertImage(
        LeafImagesCompanion(
          id: Value(id),
          filePath: Value(destPath),
          capturedAt: Value(DateTime.now()),
          fileSize: Value(fileSize),
          blurScore: Value(validationReport?.blurScore),
          brightnessScore: Value(validationReport?.brightnessScore),
        ),
      );

      return SaveResult.success(id);
    } catch (e) {
      return SaveResult.failure(AppConstants.msgImageSaveError);
    }
  }

  /// Elimina una imagen de disco y de la base de datos.
  Future<bool> deleteImage(LeafImage image) async {
    try {
      // 1. Eliminar archivo de disco
      final file = File(image.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 2. Eliminar registro de DB
      await _db.deleteImage(image.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Devuelve o crea el directorio de imágenes de la app.
  Future<Directory> _getImagesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir =
        Directory(p.join(appDocDir.path, AppConstants.imagesFolderName));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Verifica si una imagen existe en disco
  Future<bool> imageExists(String filePath) async {
    return File(filePath).exists();
  }
}
