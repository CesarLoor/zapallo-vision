import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'core/services/classifier_service.dart';

/// ClassifierProvider: acceso global al clasificador sin globals en main.dart.
/// Se inicializa una sola vez y se pasa por herencia al árbol de widgets.
class ClassifierProvider extends InheritedWidget {
  final ClassifierService classifier;

  const ClassifierProvider({
    super.key,
    required this.classifier,
    required super.child,
  });

  static ClassifierService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ClassifierProvider>();
    assert(provider != null, 'ClassifierProvider no encontrado en el árbol');
    return provider!.classifier;
  }

  @override
  bool updateShouldNotify(ClassifierProvider oldWidget) =>
      classifier != oldWidget.classifier;
}

class ZapalloApp extends StatelessWidget {
  const ZapalloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZapalloAI',
      debugShowCheckedModeBanner: false,
      theme: ZapalloTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Envolver toda la app en el FutureBuilder de carga del modelo
        return _ModelLoader(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Carga el modelo TFLite de forma asíncrona mostrando un splash screen
/// profesional mientras se inicializa. Tras la carga, expone el
/// ClassifierService a toda la app via ClassifierProvider.
class _ModelLoader extends StatefulWidget {
  final Widget child;
  const _ModelLoader({required this.child});

  @override
  State<_ModelLoader> createState() => _ModelLoaderState();
}

class _ModelLoaderState extends State<_ModelLoader>
    with SingleTickerProviderStateMixin {
  late final Future<ClassifierService> _initFuture;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadModel();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<ClassifierService> _loadModel() async {
    final svc = ClassifierService();
    try {
      await svc.initialize();
    } catch (e) {
      // Si falla, se crea el servicio sin modelo. La app puede funcionar
      // parcialmente (galería, historial). Al intentar clasificar,
      // CaptureCubit emitirá CaptureError con mensaje descriptivo.
      debugPrint('[ZapalloAI] Modelo no cargado: $e');
    }
    return svc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassifierService>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ── Splash / loading screen ──────────────────────────────
          return _SplashScreen(pulseAnim: _pulseAnim);
        }

        // ── App lista: envolver con ClassifierProvider ────────────
        return ClassifierProvider(
          classifier: snapshot.data!,
          child: widget.child,
        );
      },
    );
  }
}

/// Splash screen profesional mientras carga el modelo TFLite (~1-3 seg)
class _SplashScreen extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _SplashScreen({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZapalloTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            ScaleTransition(
              scale: pulseAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ZapalloTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ZapalloTheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 60,
                  color: ZapalloTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nombre de la app
            const Text(
              'ZapalloAI',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: ZapalloTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Diagnóstico de enfermedades foliares',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: ZapalloTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Indicador de carga
            SizedBox(
              width: 180,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor:
                        ZapalloTheme.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        ZapalloTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cargando modelo de IA...',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: ZapalloTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
