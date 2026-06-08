import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/database/app_database.dart';

import 'core/services/classifier_service.dart';

late AppDatabase db;
late ClassifierService classifier;
bool modelLoadFailed = false;
String? modelLoadError;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar base de datos
  db = AppDatabase();

  // Inicializar modelo
  classifier = ClassifierService();
  try {
    await classifier.initialize();
  } catch (e, st) {
    modelLoadFailed = true;
    modelLoadError = e.toString();
    debugPrint('Error al inicializar ClassifierService: $e\n$st');
  }

  runApp(const ZapalloApp());
}
