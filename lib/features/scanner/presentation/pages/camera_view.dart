import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/camera/camera_bloc.dart';
import '../bloc/camera/camera_event.dart';
import '../bloc/camera/camera_state.dart';
import '../bloc/camera/scan_session_bloc.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/camera/camera_buttom_buttons.dart';
import '../widgets/camera/camera_focus_mixin.dart';
import '../widgets/camera/camera_header.dart';
import '../widgets/camera/camera_loading.dart';
import '../widgets/camera/camera_preview_container.dart';
import '../widgets/image_preview_widget.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with CameraFocusMixin {
  Offset? _focusPoint;
  bool _showEdgeDetection = true;
  List<Offset>? _detectedEdges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraError) {
            AppSnackBar.error(context, state.message);
            context.pop();
          }

          // Update detected edges when available from BLoC
          if (state is CameraReady && state.detectedEdges != null) {
            if (mounted) {
              setState(() {
                _detectedEdges = state.detectedEdges;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is CameraInitial || state is CameraLoading) {
            return const CameraLoadingView(
              text: 'Initializing camera...',
            );
          }

          if (state is CameraCapturing) {
            return const CameraLoadingView(
              text: 'Processing...',
            );
          }

          if (state is ImageCaptured) {
            return ImagePreviewWidget(
              imagePath: state.imagePath,
              detectedEdges: state.detectedEdges, // Pass edges to preview
              onAddPage: () => _addPageAndContinue(context, state.imagePath),
            );
          }

          if (state is CameraReady) {
            return _buildCameraLayout(context, state, theme);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCameraLayout(
      BuildContext context,
      CameraReady state,
      ThemeData theme,
      ) {
    return Column(
      children: [
        CameraHeader(
          flashMode: state.flashMode,
          onClose: () {
            context.read<CameraBloc>().add(DisposeCameraEvent());
            context.pop();
          },
          onToggleFlash: () {
            context.read<CameraBloc>().add(ToggleFlashEvent());
          },
        ),
        const SizedBox(height: 22),
        Expanded(
          child: CameraPreviewContainer(
            controller: state.controller,
            focusPoint: _focusPoint,
            detectedEdges: _detectedEdges,
            showEdgeDetection: _showEdgeDetection,
            onTapToFocus: (details) {
              handleTapToFocus(
                context,
                details,
                state.controller,
                    () => setState(() => _focusPoint = details.localPosition),
                    () => mounted ? setState(() => _focusPoint = null) : null,
              );
            },
          ),
        ),
        CameraControls(),
      ],
    );
  }

  void _addPageAndContinue(BuildContext context, String imagePath) {
    context.read<ScanSessionBloc>().add(AddPageToSessionEvent(imagePath));
    context.read<CameraBloc>().add(RetakeImageEvent());
  }
}