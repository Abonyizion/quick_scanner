import 'package:camera/camera.dart';
import '../../domain/entities/captured_image.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_local_datasource.dart';
import '../models/captured_image_model.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDataSource dataSource;

  CameraRepositoryImpl(this.dataSource);

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    return await dataSource.getAvailableCameras();
  }

  @override
  Future<CameraController> initializeCamera(CameraDescription camera) async {
    return await dataSource.createCameraController(camera);
  }

  @override
  Future<CapturedImage> captureImage(CameraController controller) async {
    final imagePath = await dataSource.captureAndSaveImage(controller);

    return CapturedImageModel(
      path: imagePath,
      capturedAt: DateTime.now(),
    );
  }

  @override
  Future<void> setFlashMode(CameraController controller, FlashMode mode) async {
    await dataSource.setFlashMode(controller, mode);
  }

  @override
  Future<void> disposeCamera(CameraController controller) async {
    await controller.dispose();
  }
}