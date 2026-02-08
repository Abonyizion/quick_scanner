import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract class CameraLocalDataSource {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> createCameraController(CameraDescription camera);
  Future<String> captureAndSaveImage(CameraController controller);
  Future<void> setFlashMode(CameraController controller, FlashMode mode);
}

class CameraLocalDataSourceImpl implements CameraLocalDataSource {
  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    return await availableCameras();
  }

  @override
  Future<CameraController> createCameraController(
      CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    // ✅ Enable auto-focus
    await controller.setFocusMode(FocusMode.auto);

    // ✅ Enable auto-exposure
    await controller.setExposureMode(ExposureMode.auto);

    // Set flash to off
    await controller.setFlashMode(FlashMode.off);

    return controller;
  }

  @override
  Future<String> captureAndSaveImage(CameraController controller) async {
    final directory = await getTemporaryDirectory();
    final imagePath = path.join(
      directory.path,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final XFile image = await controller.takePicture();
    await File(image.path).copy(imagePath);

    return imagePath;
  }

  @override
  Future<void> setFlashMode(CameraController controller, FlashMode mode) async {
    await controller.setFlashMode(mode);
  }
}