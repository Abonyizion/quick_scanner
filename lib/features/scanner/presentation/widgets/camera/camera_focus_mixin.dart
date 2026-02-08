import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

mixin CameraFocusMixin<T extends StatefulWidget> on State<T> {
  Offset? focusPoint;

  Future<void> handleTapToFocus(
      BuildContext context,
      TapDownDetails details,
      CameraController controller,
      VoidCallback onShow,
      VoidCallback onHide,
      ) async {
    if (!controller.value.isInitialized) return;

    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final offset = details.localPosition;
      final size = renderBox.size;

      final point = Offset(
        offset.dx / size.width,
        offset.dy / size.height,
      );

      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);

      onShow();

      Future.delayed(const Duration(milliseconds: 1500), onHide);
    } catch (_) {}
  }
}
