import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../services/storage_service.dart';
import '../services/classifier_service.dart';
import '../repositories/gallery_repository.dart';
import '../repositories/capture_repository.dart';
import '../services/image_validator.dart';

final sl = GetIt.instance;

Future<void> initCoreServices() async {
  final db = AppDatabase();
  sl.registerLazySingleton<AppDatabase>(() => db);
  sl.registerLazySingleton<StorageService>(() => StorageService(db));
  sl.registerLazySingleton<GalleryRepository>(
      () => GalleryRepository(db, StorageService(db)));
}

void registerClassifier(ClassifierService svc) {
  sl.registerLazySingleton<ClassifierService>(() => svc);
  sl.registerFactory<CaptureRepository>(() => CaptureRepository(
        const ImageValidator(),
        sl<StorageService>(),
        sl<ClassifierService>(),
      ));
}
