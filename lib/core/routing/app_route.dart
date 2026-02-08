import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/scanner/presentation/pages/about_page.dart';
import '../../features/scanner/presentation/pages/camera_page.dart';
import '../../features/scanner/presentation/pages/image_enhancement_page.dart';
import '../../features/scanner/presentation/pages/pdf_view_page.dart';
import '../../features/scanner/presentation/pages/preview_page.dart';
import '../../features/scanner/presentation/pages/scan_page.dart';
import '../../features/scanner/presentation/pages/settings_page.dart';



class AppRoutes {
  static const scanPage = '/';
  static const preview = '/preview';
  static const cameraPage = '/camera';
  static const settingsPage = '/settings';
  static const pdfView = '/pdfView';
  static const aboutPage = '/aboutPage';
  static const imageEnhancement = '/imageEnhancement';



  static final appRouter = GoRouter(
    initialLocation: scanPage,
    routes: [
      GoRoute(
        path: scanPage,
        name: 'scanPage',
        builder: (context, state) => ScanPage(),
      ),

      GoRoute(
        path: aboutPage,
        name: 'aboutPage',
        builder: (context, state) => AboutPage(),
      ),

      GoRoute(
        path: preview,
        name: 'preview',
        builder: (context, state) {
          final extra = state.extra;

          // Convert whatever we get into the format PreviewPage expects
          dynamic imagePath;

          if (extra is String) {
            imagePath = extra;
          } else if (extra is List) {
            imagePath = extra.cast<String>(); // or extra.map((e) => e.toString()).toList()
          } else {
            // Handle error case
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid image data')),
            );
          }
          return PreviewPage(imagePath: imagePath);
        },
      ),
      // In your GoRouter setup
      GoRoute(
        path: cameraPage,
        name: 'camera',
        builder: (context, state) => CameraPage(),
      ),

      GoRoute(
        path: pdfView,
        name: 'pdfView',
        builder: (context, state) {
          final pdfPath = state.extra as String;
          return PDFViewPage(pdfPath: pdfPath);
        },
      ),

      GoRoute(
        path: settingsPage,
        name: 'settings',
        builder: (context, state) => SettingsPage(),
      ),

      GoRoute(
        path: imageEnhancement,
        name: 'imageEnhancement',
        builder: (context, state) {
          final imagePath = state.extra as String;

          return ImageEnhancementPage(
            imagePath: imagePath,
          );
        },
      ),

    ],
  );
}



