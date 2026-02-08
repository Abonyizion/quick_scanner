import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_route.dart';
import '../bloc/camera/camera_bloc.dart';
import '../bloc/camera/camera_event.dart';
import '../bloc/camera/scan_session_bloc.dart';

class ImagePreviewWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback onAddPage;
  final List<Offset>? detectedEdges; // Add detected edges from camera

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    required this.onAddPage,
    this.detectedEdges,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  List<Offset>? _adjustableEdges;
  int? _selectedCornerIndex;
  Size? _imageSize;

  List<Offset> _ensureCornerOrder(List<Offset> edges) {
    final sorted = [...edges];

    sorted.sort((a, b) {
      if (a.dy == b.dy) return a.dx.compareTo(b.dx);
      return a.dy.compareTo(b.dy);
    });

    final top = sorted.take(2).toList()
      ..sort((a, b) => a.dx.compareTo(b.dx));
    final bottom = sorted.skip(2).take(2).toList()
      ..sort((a, b) => b.dx.compareTo(a.dx));

    return [...top, ...bottom];
  }


  @override
  void initState() {
    super.initState();
    _adjustableEdges = widget.detectedEdges != null
        ? _ensureCornerOrder(
      widget.detectedEdges!
          .map((e) => Offset(e.dx, e.dy))
          .toList(),
    )
        : null;
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final image = Image.file(File(widget.imagePath));
    final completer = image.image.resolve(const ImageConfiguration());
    completer.addListener(ImageStreamListener((info, _) {
      if (mounted) {
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PageCounter(theme: theme),
                Text(
                  _adjustableEdges != null
                      ? 'Adjust corners if needed'
                      : 'Review your scan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  onPressed: widget.onAddPage,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// ───── Image Preview with Edge Detection ─────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildInteractivePreview(),
            ),
          ),
        ),

        /// ───── Edge Detection Helper Text ─────
        if (_adjustableEdges != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Drag corners to adjust',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        /// ───── Bottom Actions ─────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.close,
                  label: 'Retake',
                  backgroundColor: AppColors.red,
                  onPressed: () => _onRetake(context),
                ),
                if (_adjustableEdges != null)
                  _ActionButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    backgroundColor: Colors.orange,
                    onPressed: _resetEdges,
                  ),
                _ActionButton(
                  icon: Icons.check,
                  label: 'Done',
                  backgroundColor: AppColors.green,
                  onPressed: () => _onDone(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractivePreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => _onPanStart(details, constraints),
          onPanUpdate: (details) => _onPanUpdate(details, constraints),
          onPanEnd: (_) => _onPanEnd(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
              if (_adjustableEdges != null && _imageSize != null)
                CustomPaint(
                  painter: EdgeAdjustmentPainter(
                    edges: _adjustableEdges!,
                    selectedIndex: _selectedCornerIndex,
                    imageSize: _imageSize!,
                    containerSize: constraints.biggest,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_adjustableEdges == null || _imageSize == null) return;

    final localPosition = details.localPosition;

    // Find which corner is being touched
    if (_selectedCornerIndex == null) return;

    _selectedCornerIndex = _findNearestCorner(
      localPosition,
      constraints.biggest,
    );

    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_selectedCornerIndex == null || _adjustableEdges == null) return;
    if (_imageSize == null) return;

    final localPosition = details.localPosition;
    final containerSize = constraints.biggest;

    // Convert to normalized coordinates
    final normalizedPosition = _convertToNormalizedCoordinates(
      localPosition,
      containerSize,
    );

    // Update corner position
    setState(() {
      _adjustableEdges![_selectedCornerIndex!] = normalizedPosition;
    });
  }

  void _onPanEnd() {
    setState(() {
      _selectedCornerIndex = null;
    });
  }

  int? _findNearestCorner(Offset touchPosition, Size containerSize) {
    if (_adjustableEdges == null) return null;

    const touchRadius = 50.0; // Pixels
    int? nearestIndex;
    double nearestDistance = touchRadius;

    for (int i = 0; i < _adjustableEdges!.length; i++) {
      final cornerPosition = _convertToScreenCoordinates(
        _adjustableEdges![i],
        containerSize,
      );

      final distance = (touchPosition - cornerPosition).distance;

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  Offset _convertToScreenCoordinates(Offset normalized, Size containerSize) {
    if (_imageSize == null) return Offset.zero;

    // Calculate image display size maintaining aspect ratio
    final imageAspect = _imageSize!.width / _imageSize!.height;
    final containerAspect = containerSize.width / containerSize.height;

    double displayWidth, displayHeight;
    double offsetX = 0, offsetY = 0;

    if (containerAspect > imageAspect) {
      // Container is wider - fit height
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspect;
      offsetX = (containerSize.width - displayWidth) / 2;
    } else {
      // Container is taller - fit width
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspect;
      offsetY = (containerSize.height - displayHeight) / 2;
    }

    return Offset(
      offsetX + (normalized.dx * displayWidth),
      offsetY + (normalized.dy * displayHeight),
    );
  }

  Offset _convertToNormalizedCoordinates(Offset screen, Size containerSize) {
    if (_imageSize == null) return Offset.zero;

    // Calculate image display size
    final imageAspect = _imageSize!.width / _imageSize!.height;
    final containerAspect = containerSize.width / containerSize.height;

    double displayWidth, displayHeight;
    double offsetX = 0, offsetY = 0;

    if (containerAspect > imageAspect) {
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspect;
      offsetX = (containerSize.width - displayWidth) / 2;
    } else {
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspect;
      offsetY = (containerSize.height - displayHeight) / 2;
    }

    // Clamp to image bounds
    final x = ((screen.dx - offsetX) / displayWidth).clamp(0.0, 1.0);
    final y = ((screen.dy - offsetY) / displayHeight).clamp(0.0, 1.0);

    return Offset(x, y);
  }

  void _resetEdges() {
    setState(() {
      _adjustableEdges = widget.detectedEdges
          ?.map((e) => Offset(e.dx, e.dy))
          .toList();
    });
  }


  void _onRetake(BuildContext context) {
    try {
      File(widget.imagePath).deleteSync();
    } catch (_) {}

    context.read<CameraBloc>().add(RetakeImageEvent());
  }

  void _onDone(BuildContext context) {
    final sessionState = context.read<ScanSessionBloc>().state;

    final pages = sessionState is ScanSessionActive
        ? [...sessionState.scannedPages, widget.imagePath]
        : [widget.imagePath];

    // TODO: Process image with adjusted edges before saving
    // Use _adjustableEdges for perspective correction/cropping

    context.read<CameraBloc>().add(DisposeCameraEvent());

    context.pushReplacement(
      AppRoutes.preview,
      extra: pages,
    );
  }
}

/// Custom painter for drawing and highlighting adjustable edges
class EdgeAdjustmentPainter extends CustomPainter {
  final List<Offset> edges;
  final int? selectedIndex;
  final Size imageSize;
  final Size containerSize;

  EdgeAdjustmentPainter({
    required this.edges,
    required this.selectedIndex,
    required this.imageSize,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (edges.length != 4) return;

    // Calculate image display bounds
    final imageAspect = imageSize.width / imageSize.height;
    final containerAspect = containerSize.width / containerSize.height;

    double displayWidth, displayHeight;
    double offsetX = 0, offsetY = 0;

    if (containerAspect > imageAspect) {
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspect;
      offsetX = (containerSize.width - displayWidth) / 2;
    } else {
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspect;
      offsetY = (containerSize.height - displayHeight) / 2;
    }

    // Convert normalized coordinates to screen coordinates
    final screenCorners = edges.map((corner) {
      return Offset(
        offsetX + (corner.dx * displayWidth),
        offsetY + (corner.dy * displayHeight),
      );
    }).toList();

    // Draw semi-transparent overlay outside the detected area
    _drawOverlay(canvas, size, screenCorners);

    // Draw edges
    final edgePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(screenCorners[0].dx, screenCorners[0].dy);

    for (int i = 1; i < screenCorners.length; i++) {
      path.lineTo(screenCorners[i].dx, screenCorners[i].dy);
    }
    path.close();

    canvas.drawPath(path, edgePaint);

    // Draw corner handles
    for (int i = 0; i < screenCorners.length; i++) {
      _drawCornerHandle(
        canvas,
        screenCorners[i],
        isSelected: i == selectedIndex,
      );
    }

    // Draw corner labels
    _drawCornerLabels(canvas, screenCorners);
  }

  void _drawOverlay(Canvas canvas, Size size, List<Offset> corners) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    // Create path for the entire canvas
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create path for the detected document area
    final documentPath = Path()
      ..moveTo(corners[0].dx, corners[0].dy);

    for (int i = 1; i < corners.length; i++) {
      documentPath.lineTo(corners[i].dx, corners[i].dy);
    }
    documentPath.close();

    // Use difference to get the area outside the document
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      documentPath,
    );

    canvas.drawPath(overlayPath, overlayPaint);
  }

  void _drawCornerHandle(Canvas canvas, Offset position, {required bool isSelected}) {
    // Outer circle (white border)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, isSelected ? 20 : 16, outerPaint);

    // Inner circle (colored)
    final innerPaint = Paint()
      ..color = isSelected ? AppColors.yellow : AppColors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, isSelected ? 16 : 12, innerPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 4, dotPaint);
  }

  void _drawCornerLabels(Canvas canvas, List<Offset> corners) {
    final labels = ['TL', 'TR', 'BR', 'BL'];

    for (int i = 0; i < corners.length && i < labels.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Position label near corner
      final offset = Offset(
        corners[i].dx - textPainter.width / 2,
        corners[i].dy - 30,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(EdgeAdjustmentPainter oldDelegate) {
    return oldDelegate.edges != edges ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.containerSize != containerSize;
  }
}

class _PageCounter extends StatelessWidget {
  final ThemeData theme;

  const _PageCounter({required this.theme});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanSessionBloc, ScanSessionState>(
      builder: (context, state) {
        if (state is ScanSessionActive && state.scannedPages.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.collections,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  '${state.scannedPages.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox(width: 48);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}