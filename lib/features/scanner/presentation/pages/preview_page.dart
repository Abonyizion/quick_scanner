import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/camera_mode.dart';
import '../../../../core/pdf/pdf_generator.dart';
import '../bloc/camera/scan_session_bloc.dart';
import '../widgets/app_alert_dialogue.dart';
import '../widgets/app_button.dart';
import '../../../../core/routing/app_route.dart';
import '../widgets/app_snackbar.dart';
import 'image_enhancement_page.dart';

class PreviewPage extends StatefulWidget {
  final dynamic imagePath; // Can be String or List<String>

  const PreviewPage({super.key, required this.imagePath});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late List<String> _imagePaths;
  int _currentPageIndex = 0;
  bool _isProcessing = false;
  late final PageController _pageController;


  @override
  void initState() {
    super.initState();

    if (widget.imagePath is List<String>) {
      _imagePaths = List<String>.from(widget.imagePath);
    } else if (widget.imagePath is String) {
      _imagePaths = [widget.imagePath];
    } else {
      _imagePaths = [];
    }

    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  /// Crop current image


  Future<void> _cropImage() async {
    if (_imagePaths.isEmpty || _currentPageIndex >= _imagePaths.length) return;

    final imageFile = File(_imagePaths[_currentPageIndex]);
    if (!await imageFile.exists()) return;

    final cropController = CropController(
      aspectRatio: null, // Free-form (best for documents)
      defaultCrop: const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );

    final ui.Image? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Crop Page'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  final result = await cropController.croppedImage();
                  Navigator.pop(context, result);
                },
              ),
            ],
          ),
          body: CropImage(
            controller: cropController,
            image: Image.file(imageFile),
          ),
        ),
      ),
    );

    if (!mounted || croppedImage == null) return;

    final byteData =
    await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final newPath =
        '${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.png';

    await File(newPath).writeAsBytes(bytes);

    setState(() {
      _imagePaths[_currentPageIndex] = newPath;
    });
  }

  /// Delete current page
  Future<void> _deleteCurrentPage(BuildContext context, int pageIndex) async {
    // Prevent deleting if it's the last remaining page
    if (_imagePaths.isEmpty || _imagePaths.length == 1) {
      AppSnackBar.error(context, 'Cannot delete the last page');
      return;
    }

    // Ask for confirmation
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Page',
      content: 'Are you sure you want to delete page ${pageIndex + 1}?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (!confirmed) return;

    // Proceed with deletion
    try {
      final fileToDelete = File(_imagePaths[pageIndex]);
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }

    setState(() {
      _imagePaths.removeAt(pageIndex);

      // Adjust current index if needed
      if (_currentPageIndex >= _imagePaths.length && _imagePaths.isNotEmpty) {
        _currentPageIndex = _imagePaths.length - 1;
      }
    });

    // Show success message
    if (mounted) {
      AppSnackBar.success(
        context,
        'Page deleted. ${_imagePaths.length} page(s) remaining',
      );
    }
  }

  /// Navigate to previous page
  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  /// Navigate to next page
  void _nextPage() {
    if (_currentPageIndex < _imagePaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Generate PDF from all scanned images
  Future<void> _generatePDF() async {
    if (_imagePaths.isEmpty) return;

    setState(() => _isProcessing = true);
    final dir = await getApplicationDocumentsDirectory();

    try {
      final pdfPath = await compute(
        generatePdfInBackground,
        {
          'images': List<String>.from(_imagePaths),
          'dir': dir.path,
        },
      );

      if (!mounted) return;

      context.read<ScanSessionBloc>().add(ClearScanSessionEvent());
      context.push(AppRoutes.pdfView, extra: pdfPath);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to generate PDF');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }


  /// Show all pages in a grid view
  void _showAllPages(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Pages (${_imagePaths.length})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                            fontSize: 16
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Grid of pages
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      return _PageThumbnail(
                        imagePath: _imagePaths[index],
                        pageNumber: index + 1,
                        isSelected: index == _currentPageIndex,
                        onTap: () {
                          setState(() {
                            _currentPageIndex = index;
                          });
                          Navigator.pop(context);
                        },
                        onDelete: _imagePaths.length > 1
                            ? () {
                          setState(() {
                            try {
                              File(_imagePaths[index]).deleteSync();
                            } catch (e) {
                              debugPrint('Error deleting file: $e');
                            }
                            _imagePaths.removeAt(index);
                            if (_currentPageIndex >= _imagePaths.length) {
                              _currentPageIndex = _imagePaths.length - 1;
                            }
                          });
                          Navigator.pop(context);
                          AppSnackBar.success(context,
                              'Page deleted');
                        }
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_imagePaths.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(
          child: Text('No images to preview'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Page ${_currentPageIndex + 1} of ${_imagePaths.length}',
        style: TextStyle(
            fontSize: 16
        ),),
        centerTitle: true,
        leading:  Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.add_a_photo),
            tooltip: 'Add pages',
            onPressed: () {
              context.push(
                AppRoutes.cameraPage,
                extra: ScanCameraMode.append,
              );
            },
          ),
        ),
        actions: [
          // Show all pages button
          if (_imagePaths.length > 1)
            IconButton(
              onPressed:  () => _showAllPages(context),
              icon: Badge(
                label: Text('${_imagePaths.length}'),
                child: const Icon(Icons.collections),
              ),
              tooltip: 'View all pages',
            ),

          // Delete page button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () => _deleteCurrentPage(context, _currentPageIndex),

              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete page',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Main image preview with navigation
              Expanded(
                child: Stack(
                  children: [
                    // Image
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _imagePaths.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: InteractiveViewer( // pinch & pan
                                    minScale: 1,
                                    maxScale: 4,
                                    child: Image.file(
                                      File(_imagePaths[index]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      ),
                    ),

                    // Navigation arrows (only show if multiple pages)
                    if (_imagePaths.length > 1) ...[
                      // Previous button
                      if (_currentPageIndex > 0)
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              onPressed: _previousPage,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Next button
                      if (_currentPageIndex < _imagePaths.length - 1)
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              onPressed: _nextPage,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Page indicators (dots) - only show if multiple pages
              if (_imagePaths.length > 1 && _imagePaths.length <= 10)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _imagePaths.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPageIndex ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPageIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Enhance',
                        icon: Icons.auto_awesome,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        foregroundColor: theme.colorScheme.onSurface,
                        onPressed: () async {
                          final enhancedPath = await context.push<String>(
                            AppRoutes.imageEnhancement,
                            extra: _imagePaths[_currentPageIndex],
                          );

                          if (enhancedPath != null && mounted) {
                            setState(() {
                              _imagePaths[_currentPageIndex] = enhancedPath;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: _imagePaths.length > 1
                            ? 'Generate PDF'
                            : 'Done',
                        icon: Icons.check,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        onPressed: _generatePDF,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// Widget for page thumbnail in bottom sheet
class _PageThumbnail extends StatelessWidget {
  final String imagePath;
  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PageThumbnail({
    required this.imagePath,
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Page number badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pageNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Delete button
            if (onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
