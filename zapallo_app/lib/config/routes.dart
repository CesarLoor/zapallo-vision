import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/capture/capture_screen.dart';
import '../features/capture/preview_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/gallery/image_detail_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String capture = '/capture';
  static const String preview = '/preview';
  static const String gallery = '/gallery';
  static const String imageDetail = '/gallery/:id';

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
          final imagePath = state.extra as String;
          return PreviewScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: imageDetail,
        builder: (context, state) {
          final imageId = state.pathParameters['id']!;
          return ImageDetailScreen(imageId: imageId);
        },
      ),
    ],
  );
}
