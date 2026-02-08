import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeCameraEvent extends CameraEvent {}

class CaptureImageEvent extends CameraEvent {}

class ToggleFlashEvent extends CameraEvent {}

class RetakeImageEvent extends CameraEvent {}

class ProceedWithImageEvent extends CameraEvent {}

class DisposeCameraEvent extends CameraEvent {}


class CaptureFromGalleryEvent extends CameraEvent {
  final String path;
  CaptureFromGalleryEvent(this.path);
}




// Start edge detection
class StartEdgeDetectionEvent extends CameraEvent {}

/// Stop edge detection
class StopEdgeDetectionEvent extends CameraEvent {}

/// Update detected edges
class UpdateDetectedEdgesEvent extends CameraEvent {
  final List<Offset> edges;

  UpdateDetectedEdgesEvent(this.edges);
}

// Toggle edge detection on/off
class ToggleEdgeDetectionEvent extends CameraEvent {}