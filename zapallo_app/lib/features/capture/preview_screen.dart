import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../core/services/image_validator.dart';
import '../../core/services/storage_service.dart';
import '../../main.dart';
import 'cubit/capture_cubit.dart';
import 'cubit/capture_state.dart';

/// Pantalla de revisión previa al guardado.
/// Cumple HU-002, HU-003, HU-004, HU-005, FUN-002 a FUN-006
class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CaptureCubit(
        validator: const ImageValidator(
          blurThreshold: AppConstants.blurThreshold,
          brightnessMin: AppConstants.brightnessMin,
          brightnessMax: AppConstants.brightnessMax,
        ),
        storage: StorageService(db),
      )..validateImage(imagePath),
      child: _PreviewView(imagePath: imagePath),
    );
  }
}

class _PreviewView extends StatelessWidget {
  final String imagePath;
  const _PreviewView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CaptureCubit, CaptureState>(
        listener: (context, state) {
          if (state is CaptureSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppConstants.msgImageSaved),
                backgroundColor: ZapalloTheme.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Volver al home después de guardar
            context.go(AppRouter.home);
          }
          if (state is CaptureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ZapalloTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Imagen capturada ──────────────────────────────────
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),

              // ── Overlay oscuro en la parte inferior ──────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: _buildBottomContent(context, state),
                ),
              ),

              // ── Barra superior ────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('btn_back_preview'),
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Revisar imagen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              // ── Indicador de validación ───────────────────────────
              if (state is CaptureValidating)
                const Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ValidationChip(label: 'Analizando imagen...', isLoading: true),
                  ),
                ),

              if (state is CaptureValidated)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: state.report.isAcceptable
                        ? const _ValidationChip(
                            label: '✓ Imagen clara',
                            isGood: true,
                          )
                        : _ValidationChip(
                            label: '⚠ ${state.report.userMessage}',
                            isGood: false,
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context, CaptureState state) {
    if (state is CaptureSaving) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Guardando imagen...',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final isValidated = state is CaptureValidated;
    final report = isValidated ? (state as CaptureValidated).report : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila de botones: Repetir | Guardar
        Row(
          children: [
            // Botón repetir (HU-003, FUN-003)
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('btn_retake'),
                onPressed: () {
                  context.read<CaptureCubit>().reset();
                  context.pop(); // Vuelve a la cámara
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Repetir'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botón guardar (HU-005, FUN-006)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                key: const Key('btn_save'),
                onPressed: isValidated
                    ? () => context.read<CaptureCubit>().saveImage(
                          imagePath,
                          report!,
                        )
                    : null,
                icon: const Icon(Icons.save_alt_rounded, size: 20),
                label: const Text('Guardar imagen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZapalloTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chip indicador de validación en el preview
class _ValidationChip extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isGood;

  const _ValidationChip({
    required this.label,
    this.isLoading = false,
    this.isGood = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLoading
            ? Colors.black54
            : isGood
                ? ZapalloTheme.success.withOpacity(0.85)
                : ZapalloTheme.warning.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          if (isLoading) const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
