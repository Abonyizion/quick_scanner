import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;
  final List<Offset>? detectedEdges; // Add edge detection support
  final bool isEdgeDetectionEnabled;

  CameraReady({
    required this.controller,
    required this.flashMode,
    this.detectedEdges,
    this.isEdgeDetectionEnabled = false,
  });


  @override
  List<Object?> get props => [controller, flashMode];

  /// Copy with method to update state
  CameraReady copyWith({
    CameraController? controller,
    FlashMode? flashMode,
    List<Offset>? detectedEdges,
    bool? isEdgeDetectionEnabled,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      flashMode: flashMode ?? this.flashMode,
      detectedEdges: detectedEdges ?? this.detectedEdges,
      isEdgeDetectionEnabled: isEdgeDetectionEnabled ?? this.isEdgeDetectionEnabled,
    );
  }
}


class CameraCapturing extends CameraState {}

class ImageCaptured extends CameraState {
  final String imagePath;
  final List<Offset>? detectedEdges;

  ImageCaptured(
      this.imagePath,
      this.detectedEdges);

  @override
  List<Object?> get props => [imagePath];
}

class CameraError extends CameraState {
  final String message;

  CameraError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Edge detection in progress
class EdgeDetecting extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;

  EdgeDetecting({
    required this.controller,
    required this.flashMode,
  });
}