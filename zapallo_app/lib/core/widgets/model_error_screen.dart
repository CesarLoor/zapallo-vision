import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Pantalla que se muestra cuando el modelo TFLite no se carga correctamente.
/// Ofrece diagnóstico del problema y opciones de recuperación.
class ModelErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ModelErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZapalloTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ZapalloTheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: ZapalloTheme.error,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Modelo no disponible',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ZapalloTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'No se pudo cargar el modelo de detección. '
                  'Verifica que los archivos estén correctamente instalados.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    color: ZapalloTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8F0E8)),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: ZapalloTheme.textHint,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(AppRouter.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Ver galería'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
