import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';

/// Pantalla de cámara.
/// Cumple HU-001, HU-002, FUN-001, FUN-002
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPhoto = false;
  bool _hasPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ── Permisos (HU-001, FUN-012) ────────────────────────────────

  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _initCamera();
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() => _hasPermission = true);
        await _initCamera();
      } else {
        setState(() {
          _hasPermission = false;
          _errorMessage = AppConstants.msgPermissionCamera;
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
        _errorMessage = AppConstants.msgPermissionCamera;
      });
    }
  }

  // ── Inicialización cámara ─────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _errorMessage = 'No se encontró cámara en este dispositivo.');
        return;
      }

      final controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error al inicializar la cámara.');
    }
  }

  // ── Captura (HU-002, FUN-002) ─────────────────────────────────

  Future<void> _takePhoto() async {
    if (_controller == null || !_isInitialized || _isTakingPhoto) return;

    setState(() => _isTakingPhoto = true);

    try {
      // Pequeña pausa para estabilización
      await Future.delayed(const Duration(milliseconds: 100));
      final photo = await _controller!.takePicture();

      if (!mounted) return;

      // Navegar a preview pasando la ruta del archivo
      context.push(AppRouter.preview, extra: photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al capturar la imagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Sin permiso
    if (!_hasPermission || _errorMessage != null) {
      return _PermissionErrorView(
        message: _errorMessage ?? AppConstants.msgPermissionCamera,
        onRetry: _checkPermissionAndInit,
        onOpenSettings: openAppSettings,
      );
    }

    // Cargando cámara
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview de cámara
        CameraPreview(_controller!),

        // Overlay: guía visual de encuadre
        _CameraOverlay(),

        // Barra superior con botón de regreso
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(),
        ),

        // Barra inferior con controles
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('btn_back_camera'),
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Capturar hoja de zapallo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Equilibrar el botón de regreso
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instrucción
          Text(
            'Centra la hoja dentro del recuadro',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 24),
          // Botón de captura
          GestureDetector(
            key: const Key('btn_take_photo'),
            onTap: _isTakingPhoto ? null : _takePhoto,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTakingPhoto
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: _isTakingPhoto
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        color: ZapalloTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: ZapalloTheme.primary,
                      size: 34,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Guía visual de encuadre
class _CameraOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final halfW = size.width * 0.38;
    final halfH = halfW * 0.75;
    const cornerLen = 24.0;
    const r = 8.0;

    // Esquinas del rectángulo guía
    final corners = [
      // Top-left
      [Offset(cx - halfW + r, cy - halfH),
       Offset(cx - halfW + cornerLen, cy - halfH),
       Offset(cx - halfW, cy - halfH + r),
       Offset(cx - halfW, cy - halfH + cornerLen)],
      // Top-right
      [Offset(cx + halfW - cornerLen, cy - halfH),
       Offset(cx + halfW - r, cy - halfH),
       Offset(cx + halfW, cy - halfH + r),
       Offset(cx + halfW, cy - halfH + cornerLen)],
      // Bottom-left
      [Offset(cx - halfW, cy + halfH - cornerLen),
       Offset(cx - halfW, cy + halfH - r),
       Offset(cx - halfW + r, cy + halfH),
       Offset(cx - halfW + cornerLen, cy + halfH)],
      // Bottom-right
      [Offset(cx + halfW, cy + halfH - cornerLen),
       Offset(cx + halfW, cy + halfH - r),
       Offset(cx + halfW - r, cy + halfH),
       Offset(cx + halfW - cornerLen, cy + halfH)],
    ];

    for (final c in corners) {
      canvas.drawLine(c[0], c[1], paint);
      canvas.drawLine(c[2], c[3], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vista de error / sin permiso
class _PermissionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _PermissionErrorView({
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZapalloTheme.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZapalloTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: ZapalloTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Permiso de cámara necesario',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ZapalloTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  color: ZapalloTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('btn_grant_permission'),
                  onPressed: onRetry,
                  child: const Text('Conceder permiso'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('btn_open_settings'),
                  onPressed: onOpenSettings,
                  child: const Text('Abrir configuración'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
