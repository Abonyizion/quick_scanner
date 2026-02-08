
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


class CameraHeader extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onClose;
  final VoidCallback onToggleFlash;

  const CameraHeader({
    super.key,
    required this.flashMode,
    required this.onClose,
    required this.onToggleFlash,
  });

  IconData _icon() {
    switch (flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  String _label() =>
      flashMode == FlashMode.always ?
      'On' : flashMode == FlashMode.auto ?
      'Auto' : 'Off';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(icon:
            const Icon(Icons.close),
                onPressed: onClose),
            const Spacer(),
            Text(
              'Position document in frame',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14
              ),
            ),
            const Spacer(),
            Column(
              children: [
                IconButton(icon:
                Icon(_icon()),
                    onPressed: onToggleFlash),
                Text(_label(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 10
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
