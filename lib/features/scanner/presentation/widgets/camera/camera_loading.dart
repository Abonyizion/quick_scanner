
import 'package:flutter/material.dart';

class CameraLoadingView extends StatelessWidget {
  final String text;

  const CameraLoadingView({super.key,
    required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 12
          ),),
        ],
      ),
    );
  }
}
