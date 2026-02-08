import 'package:flutter/material.dart';

/// Shows a confirmation dialog and returns true if confirmed, false otherwise
Future<bool> showConfirmationDialog({

  required BuildContext context,
  required String title,
  required String content,
  String cancelText = 'Cancel',
  String confirmText = 'Delete',
  Color confirmColor = Colors.red,
}) async {
  final theme = Theme.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title,
        style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
            fontSize: 19
        ),),
      content: Text(content,
        style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontSize: 14
        ),),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    ),
  );

  return result ?? false; // Default to false if dismissed
}
