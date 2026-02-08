import 'dart:io';
import '../../features/scanner/domain/entities/image_enhancement_mode.dart';
import '../image_processing/process_scanned_image.dart';


Future<String> enhanceInBackground(Map<String, dynamic> args) async {
  final processor = ProcessScannedImage();
  final file = File(args['path'] as String);
  final mode = args['mode'] as ImageEnhancementMode;

  final result = await processor.enhanceImage(file, mode: mode);
  return result.path;
}
