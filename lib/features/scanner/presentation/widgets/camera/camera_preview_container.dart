import 'package:flutter/material.dart';
import '../../bloc/camera/painter/document_guide_painter.dart';
import 'edge_deterction_overlay.dart';
import 'focus_indicator.dart';
import 'helper_hint.dart';
import 'package:camera/camera.dart';



class CameraPreviewContainer extends StatelessWidget {
  final CameraController controller;
  final Offset? focusPoint;
  final Function(TapDownDetails) onTapToFocus;
  final List<Offset>? detectedEdges;
  final bool showEdgeDetection;

  const CameraPreviewContainer({
    super.key,
    required this.controller,
    required this.focusPoint,
    required this.onTapToFocus,
    this.detectedEdges,
    this.showEdgeDetection = true,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              onTapDown: onTapToFocus,
              child: CameraPreview(controller),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 12),
              child: CustomPaint(
                painter: DocumentGuidePainter(
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
              ),
            ),


            if (focusPoint != null)
              FocusIndicator(position: focusPoint!),

            const HelperHint(),
          ],
        ),
      ),
    );
  }
}
