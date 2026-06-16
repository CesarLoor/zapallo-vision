import 'package:flutter_test/flutter_test.dart';
import 'package:zapallo_app/app.dart';
import 'package:zapallo_app/core/database/app_database.dart';
import 'package:zapallo_app/core/di/service_locator.dart';
import 'package:zapallo_app/core/services/storage_service.dart';
import 'package:zapallo_app/core/repositories/gallery_repository.dart';

void main() {
  setUp(() {
    sl.reset();
    final db = AppDatabase.forTesting();
    sl.registerLazySingleton<AppDatabase>(() => db);
    sl.registerLazySingleton<StorageService>(() => StorageService(db));
    sl.registerLazySingleton<GalleryRepository>(
        () => GalleryRepository(db, StorageService(db)));
  });

  testWidgets('Home screen carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ZapalloApp());

    // El FutureBuilder del modelo splash se queda en loading; no hacemos pumpAndSettle
    // porque el modelo TFLite no está disponible en test environment.
    expect(find.text('ZapalloAI'), findsOneWidget);
  });
}
