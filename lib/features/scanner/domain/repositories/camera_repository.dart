import 'package:camera/camera.dart';
import '../entities/captured_image.dart';

abstract class CameraRepository {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> initializeCamera(CameraDescription camera);
  Future<CapturedImage> captureImage(CameraController controller);
  Future<void> setFlashMode(CameraController controller, FlashMode mode);
  Future<void> disposeCamera(CameraController controller);
}