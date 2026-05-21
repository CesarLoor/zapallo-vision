import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class ZapalloApp extends StatelessWidget {
  const ZapalloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZapalloAI',
      debugShowCheckedModeBanner: false,
      theme: ZapalloTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
