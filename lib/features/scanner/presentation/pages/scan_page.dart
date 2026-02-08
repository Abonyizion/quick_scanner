
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_route.dart';
import '../../domain/usecases/request_camera_permission.dart';
import '../bloc/camera/scan_session_bloc.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snackbar.dart';


class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {

  final RequestCameraPermission _requestCameraPermission =
  RequestCameraPermission();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Start a new scan session
    context.read<ScanSessionBloc>().add(StartScanSessionEvent());
  }


  Future<void> _captureImage() async {
    final permissionStatus = await _requestCameraPermission();

    if (!mounted) return;

    if (permissionStatus != CameraPermissionStatus.granted) {
      AppSnackBar.error(
        context,
        permissionStatus == CameraPermissionStatus.permanentlyDenied
            ? 'Camera permission permanently denied. Enable it from settings.'
            : 'Camera permission is required to scan documents',
      );

      if (permissionStatus == CameraPermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }

      return;
    }
    // Start a fresh session before opening camera
    context.read<ScanSessionBloc>().add(StartScanSessionEvent());

    // Navigate to in-app camera
    context.push(AppRoutes.cameraPage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Centered title
                    const Center(
                      child: Text(
                        'QuickScan PDF',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Cancel/close button at top-right
                    Positioned(
                      top: -22,
                      right: -8,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                        color: AppColors.white,),
                        onPressed: () {
                          Navigator.of(context).pop(); // closes the drawer
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home_filled),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.push(AppRoutes.settingsPage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                   context.push(AppRoutes.aboutPage);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Home '),
        centerTitle: true,
        // Remove settings button if it exists here
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.document_scanner,
                    size: 90,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'QuickScan PDF',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    fontSize: 28
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scan your documents in seconds',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),

          //  Loader overlay (prevents page flash)
          if (_isProcessing)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _captureImage,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Document'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
