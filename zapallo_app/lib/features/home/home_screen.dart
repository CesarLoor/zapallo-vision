import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Pantalla principal — punto de entrada de la app.
/// Cumple RNF-001: flujo de max 3 pasos (Home → Cámara → Guardar)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZapalloTheme.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  children: [
                    // Logo / ícono de la app
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ZapalloAI',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detector de enfermedades foliares\nen plantas de zapallo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.80),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Tarjeta de acciones ───────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chip de estado offline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ZapalloTheme.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: ZapalloTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Modo offline — sin internet',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ZapalloTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón principal: Capturar imagen
                    _HomeActionButton(
                      id: 'btn_capture',
                      icon: Icons.camera_alt_rounded,
                      label: 'Capturar imagen',
                      subtitle: 'Fotografía una hoja de zapallo',
                      isPrimary: true,
                      onTap: () => context.push(AppRouter.capture),
                    ),

                    const SizedBox(height: 12),

                    // Botón secundario: Ver galería
                    _HomeActionButton(
                      id: 'btn_gallery',
                      icon: Icons.photo_library_rounded,
                      label: 'Ver imágenes guardadas',
                      subtitle: 'Galería local de capturas',
                      isPrimary: false,
                      onTap: () => context.push(AppRouter.gallery),
                    ),

                    const SizedBox(height: 24),

                    // Nota de privacidad
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: ZapalloTheme.textHint,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tus imágenes nunca se envían a internet',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: ZapalloTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Universidad
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'ESPE · Tesis de Grado 2026',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de acción en el home
class _HomeActionButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _HomeActionButton({
    required this.id,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? ZapalloTheme.primary : ZapalloTheme.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key(id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : ZapalloTheme.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : ZapalloTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary
                            ? Colors.white
                            : ZapalloTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.75)
                            : ZapalloTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : ZapalloTheme.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
