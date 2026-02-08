import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class ToggleFlash {
  final CameraRepository repository;

  ToggleFlash(this.repository);

  Future<void> call(CameraController controller, FlashMode mode) async {
    await repository.setFlashMode(controller, mode);
  }
}