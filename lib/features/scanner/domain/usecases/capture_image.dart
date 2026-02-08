import 'package:camera/camera.dart';
import '../entities/captured_image.dart';
import '../repositories/camera_repository.dart';

class CaptureImage {
  final CameraRepository repository;

  CaptureImage(this.repository);

  Future<CapturedImage> call(CameraController controller) async {
    return await repository.captureImage(controller);
  }
}