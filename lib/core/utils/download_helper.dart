import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static Future<File?> savePdf({
    required BuildContext context,
    required File file,
    String? fileName,
  }) async {
    try {
      final directory = await _getDownloadDirectory();
      final name = fileName ??
          'QuickScan_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedFile = await file.copy('${directory.path}/$name');
      return savedFile;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return await getApplicationDocumentsDirectory();
  }
}
