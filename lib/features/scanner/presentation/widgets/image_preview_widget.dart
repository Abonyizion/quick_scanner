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

        /// ───── Image Preview ─────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildInteractivePreview(),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
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