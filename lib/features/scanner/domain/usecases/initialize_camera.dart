import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class InitializeCamera {
  final CameraRepository repository;

  InitializeCamera(this.repository);

  Future<CameraController> call() async {
    final cameras = await repository.getAvailableCameras();

    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    return await repository.initializeCamera(cameras.first);
  }
}