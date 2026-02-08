import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/image_enhancement/enhanceInBackground.dart';
import '../../domain/entities/image_enhancement_mode.dart';


class ImageEnhancementPage extends StatefulWidget {
  final String imagePath;

  const ImageEnhancementPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageEnhancementPage> createState() => _ImageEnhancementPageState();
}

class _ImageEnhancementPageState extends State<ImageEnhancementPage> {

  late final String _originalImagePath;
  late String _currentImagePath;


  ImageEnhancementMode _selectedMode = ImageEnhancementMode.auto;
  bool _isProcessing = false;
 //final _processImage = ProcessScannedImage();

  final _modes = [
    (ImageEnhancementMode.auto, 'Auto', Icons.auto_awesome),
    (ImageEnhancementMode.blackAndWhite, 'B&W', Icons.contrast),
    (ImageEnhancementMode.grayscale, 'Gray', Icons.filter_b_and_w),
    (ImageEnhancementMode.color, 'Color', Icons.palette),
    (ImageEnhancementMode.sharpen, 'Sharpen', Icons.center_focus_strong),
    (ImageEnhancementMode.highContrast, 'Contrast', Icons.tonality),
    (ImageEnhancementMode.document, 'Doc', Icons.description),
    (ImageEnhancementMode.lowLight, 'Low Light', Icons.dark_mode),
    (ImageEnhancementMode.vivid, 'Vivid', Icons.flash_on),
  ];




  @override
  void initState() {
    super.initState();
    _originalImagePath = widget.imagePath;
    _currentImagePath = widget.imagePath;

    // Delay auto-enhance until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyEnhancement();
    });
  }


  Future<void> _applyEnhancement() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final newPath = await compute(
        enhanceInBackground,
        {
          'path': _originalImagePath, //  ALWAYS from original
          'mode': _selectedMode,
        },
      );

      if (!mounted) return;

      await FileImage(File(newPath)).evict();

      setState(() {
        _currentImagePath = newPath;
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Enhancement error: $e');
      if (mounted) setState(() => _isProcessing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhance Image',
          style: TextStyle(
              fontSize: 16
          ),),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isProcessing
                ? null
                : () {
              // Return enhanced image path
              context.pop(_currentImagePath);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : Image.file(
                  File(_currentImagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Enhancement mode selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhancement Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 14
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _modes.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _EnhancementModeChip(
                          label: m.$2,
                          icon: m.$3,
                          isSelected: _selectedMode == m.$1,
                          onTap: _isProcessing
                              ? null
                              : () {
                            setState(() => _selectedMode = m.$1);
                            _applyEnhancement();
                          },
                        ),
                      );
                    }).toList(),
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancementModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;


  const _EnhancementModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}