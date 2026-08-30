import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../core/repositories/capture_repository.dart';
import '../../core/di/service_locator.dart';
import 'cubit/capture_cubit.dart';
import 'cubit/capture_state.dart';

/// Pantalla de revisión previa al guardado.
/// Cumple HU-002, HU-003, HU-004, HU-005, FUN-002 a FUN-006
class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final repo = sl<CaptureRepository>();
    return BlocProvider(
      create: (_) => CaptureCubit(repository: repo)..validateImage(imagePath),
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
            context.go(AppRouter.home);
          }
          if (state is CaptureClassified) {
            // Ir a pantalla de diagnóstico
            context.go(AppRouter.diagnosis, extra: {
              'imagePath': state.imagePath,
              'result': state.result,
              'validationReport': state.validationReport,
            });
          }
          if (state is CaptureNotLeaf) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ZapalloTheme.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.0),
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

              // ── Indicador de validación/clasificación ────────────
              if (state is CaptureValidating || state is CaptureClassifying)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ValidationChip(
                      label: state is CaptureClassifying
                          ? 'Analizando enfermedad...'
                          : 'Validando calidad...',
                      isLoading: true,
                    ),
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
    if (state is CaptureSaving || state is CaptureClassifying) {
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 12),
            Text(
              state is CaptureClassifying
                  ? 'Analizando hoja...'
                  : 'Guardando...',
              style: const TextStyle(
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
    final report = isValidated ? state.report : null;
    final isNotLeaf = state is CaptureNotLeaf;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNotLeaf) ...[
          Text(
            state.message,
            key: const Key('not_leaf_message'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('btn_retake'),
                onPressed: () {
                  context.read<CaptureCubit>().reset();
                  context.pop();
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
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                key: const Key('btn_analyze'),
                onPressed: isValidated
                    ? () => context.read<CaptureCubit>().classifyImage(
                          imagePath,
                          report!,
                        )
                    : null,
                icon: const Icon(Icons.analytics_outlined, size: 20),
                label: const Text('Analizar Hoja'),
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
                ? ZapalloTheme.success.withValues(alpha: 0.85)
                : ZapalloTheme.warning.withValues(alpha: 0.9),
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
