import '../../domain/entities/captured_image.dart';

class CapturedImageModel extends CapturedImage {
  CapturedImageModel({
    required super.path,
    required super.capturedAt,
  });

  factory CapturedImageModel.fromEntity(CapturedImage entity) {
    return CapturedImageModel(
      path: entity.path,
      capturedAt: entity.capturedAt,
    );
  }

  CapturedImage toEntity() {
    return CapturedImage(
      path: path,
      capturedAt: capturedAt,
    );
  }
}