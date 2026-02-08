import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class RequestCameraPermission {
  Future<CameraPermissionStatus> call() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return CameraPermissionStatus.granted;
    }

    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }

    return CameraPermissionStatus.denied;
  }
}
