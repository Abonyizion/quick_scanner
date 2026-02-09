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
  final String imagePath;

  CaptureFromGalleryEvent(this.imagePath);
}