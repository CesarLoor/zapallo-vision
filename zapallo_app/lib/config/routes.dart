import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/capture/preview_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/gallery/image_detail_screen.dart';
import '../features/gallery/cubit/gallery_cubit.dart';
import '../features/diagnosis/diagnosis_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String capture = '/capture';
  static const String preview = '/preview';
  static const String gallery = '/gallery';
  static const String imageDetail = '/gallery/:id';
  static const String diagnosis = '/diagnosis';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: capture,
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: preview,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! String || extra.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(home);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return PreviewScreen(imagePath: extra);
        },
      ),
      GoRoute(
        path: gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: imageDetail,
        builder: (context, state) {
          final imageId = state.pathParameters['id'];
          if (imageId == null || imageId.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(gallery);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final cubit = state.extra is GalleryCubit ? state.extra as GalleryCubit : null;
          return ImageDetailScreen(imageId: imageId, cubit: cubit);
        },
      ),
      GoRoute(
        path: diagnosis,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(home);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final map = extra;
          final imagePath = map['imagePath'];
          final result = map['result'];
          if (imagePath is! String || imagePath.isEmpty || result == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(home);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return DiagnosisScreen(
            imagePath: imagePath,
            result: result,
            validationReport: map['validationReport'],
          );
        },
      ),
    ],
  );
}
