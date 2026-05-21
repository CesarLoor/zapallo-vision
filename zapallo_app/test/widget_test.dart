import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zapallo_app/app.dart';
import 'package:zapallo_app/core/database/app_database.dart';
import 'package:zapallo_app/main.dart' as app_main;

void main() {
  setUp(() {
    // Inicializar BD en memoria para tests
    app_main.db = AppDatabase.forTesting();
  });

  testWidgets('Home screen carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const ZapalloApp());
    await tester.pumpAndSettle();

    // Verifica que el título de la app aparece
    expect(find.text('ZapalloAI'), findsOneWidget);

    // Verifica que los botones de acción están presentes
    expect(find.byKey(const Key('btn_capture')), findsOneWidget);
    expect(find.byKey(const Key('btn_gallery')), findsOneWidget);
  });
}
