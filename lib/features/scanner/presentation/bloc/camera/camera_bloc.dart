import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/capture_image.dart';
import '../../../domain/usecases/initialize_camera.dart';
import '../../../domain/usecases/toggle_flash.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCamera initializeCamera;
  final CaptureImage captureImage;
  final ToggleFlash toggleFlash;

  CameraController? _controller;
  FlashMode _currentFlashMode = FlashMode.off;

  bool _edgeDetectionEnabled = false;
  List<Offset>? _lastDetectedEdges;

  CameraBloc({
    required this.initializeCamera,
    required this.captureImage,
    required this.toggleFlash,
  }) : super(CameraInitial()) {
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<CaptureImageEvent>(_onCaptureImage);
    on<ToggleFlashEvent>(_onToggleFlash);
    on<RetakeImageEvent>(_onRetakeImage);
    on<DisposeCameraEvent>(_onDisposeCamera);

    // 🔍 Edge detection
    on<StartEdgeDetectionEvent>(_onStartEdgeDetection);
    on<StopEdgeDetectionEvent>(_onStopEdgeDetection);
    on<ToggleEdgeDetectionEvent>(_onToggleEdgeDetection);
    on<UpdateDetectedEdgesEvent>(_onUpdateDetectedEdges);

  }

  // ─────────────────────────────────────────────
  // Camera lifecycle
  // ─────────────────────────────────────────────

  Future<void> _onInitializeCamera(
      InitializeCameraEvent event,
      Emitter<CameraState> emit,
      ) async {
    try {
      emit(CameraLoading());

      _controller = await initializeCamera();
      await _controller!.setFlashMode(FlashMode.off);

      _currentFlashMode = FlashMode.off;

      emit(CameraReady(
        controller: _controller!,
        flashMode: _currentFlashMode,
        detectedEdges: null,
        isEdgeDetectionEnabled: false,
      ));
    } catch (e) {
      emit(CameraError('Failed to initialize camera: $e'));
    }
  }

  Future<void> _onDisposeCamera(
      DisposeCameraEvent event,
      Emitter<CameraState> emit,
      ) async {
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }

  // ─────────────────────────────────────────────
  // Capture
  // ─────────────────────────────────────────────

  Future<void> _onCaptureImage(
      CaptureImageEvent event,
      Emitter<CameraState> emit,
      ) async {
    if (_controller == null) return;

    try {
      emit(CameraCapturing());

      final file = await captureImage(_controller!);

      emit(ImageCaptured(
        file.path,
        _edgeDetectionEnabled ? _lastDetectedEdges : null,
      ));
    } catch (e) {
      emit(CameraError('Failed to capture image: $e'));
    }
  }

  Future<void> _onRetakeImage(
      RetakeImageEvent event,
      Emitter<CameraState> emit,
      ) async {
    if (_controller == null) return;

    emit(CameraReady(
      controller: _controller!,
      flashMode: _currentFlashMode,
      detectedEdges: _edgeDetectionEnabled ? _lastDetectedEdges : null,
      isEdgeDetectionEnabled: _edgeDetectionEnabled,
    ));
  }

  // ─────────────────────────────────────────────
  // Flash
  // ─────────────────────────────────────────────

  Future<void> _onToggleFlash(
      ToggleFlashEvent event,
      Emitter<CameraState> emit,
      ) async {
    if (_controller == null || state is! CameraReady) return;

    try {
      FlashMode newMode;
      switch (_currentFlashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        default:
          newMode = FlashMode.off;
      }

      await toggleFlash(_controller!, newMode);
      _currentFlashMode = newMode;

      emit((state as CameraReady).copyWith(flashMode: newMode));
    } catch (e) {
      emit(CameraError('Failed to toggle flash: $e'));
    }
  }

  // ─────────────────────────────────────────────
  // Edge Detection
  // ─────────────────────────────────────────────

  void _onStartEdgeDetection(
      StartEdgeDetectionEvent event,
      Emitter<CameraState> emit,
      ) {
    _edgeDetectionEnabled = true;

    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(
        isEdgeDetectionEnabled: true,
      ));
    }
  }

  void _onStopEdgeDetection(
      StopEdgeDetectionEvent event,
      Emitter<CameraState> emit,
      ) {
    _edgeDetectionEnabled = false;
    _lastDetectedEdges = null;

    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(
        detectedEdges: null,
        isEdgeDetectionEnabled: false,
      ));
    }
  }

  void _onToggleEdgeDetection(
      ToggleEdgeDetectionEvent event,
      Emitter<CameraState> emit,
      ) {
    _edgeDetectionEnabled = !_edgeDetectionEnabled;

    if (state is CameraReady) {
      emit((state as CameraReady).copyWith(
        isEdgeDetectionEnabled: _edgeDetectionEnabled,
        detectedEdges: _edgeDetectionEnabled ? _lastDetectedEdges : null,
      ));
    }
  }

  void _onUpdateDetectedEdges(
      UpdateDetectedEdgesEvent event,
      Emitter<CameraState> emit,
      ) {
    if (!_edgeDetectionEnabled || state is! CameraReady) return;

    _lastDetectedEdges = event.edges;

    emit((state as CameraReady).copyWith(
      detectedEdges: event.edges,
    ));
  }
}
