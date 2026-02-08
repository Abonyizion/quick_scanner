import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';


class FocusIndicator extends StatelessWidget {
  final Offset position;

  const FocusIndicator({super.key,
    required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 40,
      top: position.dy - 40,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.2, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (_, scale, __) => Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.yellow, width: 2),
            ),
            child: const Icon(Icons.center_focus_strong, color: AppColors.yellow),
          ),
        ),
      ),
    );
  }
}
