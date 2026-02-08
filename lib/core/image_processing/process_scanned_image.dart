import 'dart:io';
import 'package:image/image.dart' as img;
import '../../features/scanner/domain/entities/image_enhancement_mode.dart';

class ProcessScannedImage {
  /// Enhance image quality for document scanning
  Future<File> enhanceImage(
      File imageFile, {
        ImageEnhancementMode mode = ImageEnhancementMode.auto,
      }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    late img.Image processed;

    switch (mode) {
      case ImageEnhancementMode.blackAndWhite:
        processed = _convertToBlackAndWhite(image);
        break;

      case ImageEnhancementMode.grayscale:
        processed = _convertToGrayscale(image);
        break;

      case ImageEnhancementMode.color:
        processed = _enhanceColor(image);
        break;

      case ImageEnhancementMode.sharpen:
        processed = _sharpen(image);
        break;

      case ImageEnhancementMode.highContrast:
        processed = _highContrast(image);
        break;

      case ImageEnhancementMode.document:
        processed = _documentOptimize(image);
        break;

      case ImageEnhancementMode.lowLight:
        processed = _lowLight(image);
        break;

      case ImageEnhancementMode.vivid:
        processed = _vivid(image);
        break;

      case ImageEnhancementMode.auto:
      default:
        processed = _autoEnhance(image);
        break;
    }

    final enhancedFile = File('${imageFile.path}_${mode.name}.png');
    await enhancedFile.writeAsBytes(img.encodePng(processed));

    return enhancedFile;
  }

  /* ===================== MODES ===================== */

  /// Auto-enhance (balanced)
  img.Image _autoEnhance(img.Image image) {
    var out = img.adjustColor(image, contrast: 1.2, brightness: 1.05);
    return _sharpen(out, mild: true);
  }

  /// Pure B&W for text
  img.Image _convertToBlackAndWhite(img.Image image) {
    var gray = img.grayscale(image);
    gray = img.adjustColor(gray, contrast: 1.6);

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final l = img.getLuminance(gray.getPixel(x, y));
        gray.setPixel(
          x,
          y,
          l > 140
              ? img.ColorRgb8(255, 255, 255)
              : img.ColorRgb8(0, 0, 0),
        );
      }
    }
    return gray;
  }

  /// Grayscale with clarity
  img.Image _convertToGrayscale(img.Image image) {
    var out = img.grayscale(image);
    return img.adjustColor(out, contrast: 1.3);
  }

  /// Color documents
  img.Image _enhanceColor(img.Image image) {
    return img.adjustColor(
      image,
      saturation: 1.2,
      contrast: 1.15,
      brightness: 1.05,
    );
  }

  /// Sharpen only
  img.Image _sharpen(img.Image image, {bool mild = false}) {
    return img.convolution(
      image,
      filter: mild
          ? [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ]
          : [
        -1, -1, -1,
        -1,  9, -1,
        -1, -1, -1
      ],
    );
  }

  /// High contrast mode
  img.Image _highContrast(img.Image image) {
    var out = img.adjustColor(image, contrast: 1.8);
    return _sharpen(out, mild: true);
  }

  /// Document-optimized (BEST for PDFs)
  img.Image _documentOptimize(img.Image image) {
    var out = img.grayscale(image);
    out = img.adjustColor(out, contrast: 1.7, brightness: 1.1);
    return _sharpen(out, mild: true);
  }

  /// Low-light photos
  img.Image _lowLight(img.Image image) {
    return img.adjustColor(
      image,
      brightness: 1.25,
      contrast: 1.3,
      saturation: 1.1,
    );
  }

  /// Vivid (color pop)
  img.Image _vivid(img.Image image) {
    return img.adjustColor(
      image,
      saturation: 1.4,
      contrast: 1.25,
      brightness: 1.05,
    );
  }
}
