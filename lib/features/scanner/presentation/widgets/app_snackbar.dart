// lib/core/utils/app_snackbar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';


class AppSnackBar {
  // Private constructor
  AppSnackBar._();

  /// Shows a beautiful floating snackbar
  /// Usage: AppSnackBar.show(context, "Success!", Colors.green);
  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.blueAccent,
        Duration duration = const Duration(seconds: 2),
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          height: 50,
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: duration,
        elevation: 6,
      ),
    );
  }

  // Quick shortcuts
  static void success(BuildContext context, String message) =>
      show(context, message, backgroundColor: AppColors.green);

  static void error(BuildContext context, String message) =>
      show(context, message, backgroundColor: AppColors.red);

  static void warning(BuildContext context, String message) =>
      show(context, message, backgroundColor: Colors.orange.shade700);

  static void info(BuildContext context, String message) =>
      show(context, message, backgroundColor: Colors.blueAccent);
}