import 'dart:ui' show Color, Rect, Size;

/// A rectangle in normalized coordinates (0 to 1) of the camera frame or photo.
class BoundingBox {
  const BoundingBox({required this.x, required this.y, required this.width, required this.height});

  final double x;
  final double y;
  final double width;
  final double height;

  factory BoundingBox.fromMap(Map<Object?, Object?> map) => BoundingBox(
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        width: (map['width'] as num).toDouble(),
        height: (map['height'] as num).toDouble(),
      );

  Map<String, double> toMap() => {'x': x, 'y': y, 'width': width, 'height': height};

  @override
  String toString() => 'BoundingBox($x, $y, $width, $height)';
}

class DetectedPlate {
  const DetectedPlate({
    required this.plate,
    required this.ocrConfidence,
    required this.detectionConfidence,
    required this.bbox,
    required this.country,
    required this.countryCode,
    required this.countryConfidence,
  });

  final String plate;
  final double ocrConfidence;
  final double detectionConfidence;
  final BoundingBox bbox;
  final String country;

  /// ISO 3166-1 alpha-2 code, or null when the country is unknown.
  final String? countryCode;
  final double countryConfidence;

  factory DetectedPlate.fromMap(Map<Object?, Object?> map) => DetectedPlate(
        plate: map['plate'] as String,
        ocrConfidence: (map['ocrConfidence'] as num).toDouble(),
        detectionConfidence: (map['detectionConfidence'] as num).toDouble(),
        bbox: BoundingBox.fromMap(map['bbox'] as Map<Object?, Object?>),
        country: map['country'] as String,
        countryCode: map['countryCode'] as String?,
        countryConfidence: (map['countryConfidence'] as num).toDouble(),
      );

  @override
  String toString() => 'DetectedPlate($plate, $country)';
}

/// Size of the camera frame the plates were read from, in pixels.
class FrameInfo {
  const FrameInfo({required this.frameWidth, required this.frameHeight});

  final double frameWidth;
  final double frameHeight;

  /// Maps [bbox] to a rect in a view of [view] size that shows the frame scaled to fill (like the camera view).
  Rect toViewRect(BoundingBox bbox, Size view) {
    final scale = [view.width / frameWidth, view.height / frameHeight].reduce((a, b) => a > b ? a : b);
    final displayedWidth = frameWidth * scale;
    final displayedHeight = frameHeight * scale;
    final offsetX = (view.width - displayedWidth) / 2;
    final offsetY = (view.height - displayedHeight) / 2;
    return Rect.fromLTWH(
      offsetX + bbox.x * displayedWidth,
      offsetY + bbox.y * displayedHeight,
      bbox.width * displayedWidth,
      bbox.height * displayedHeight,
    );
  }
}

enum AlprAccelerator { gpu, cpu }

class AlprConfig {
  const AlprConfig({this.detectionThreshold, this.ocrThreshold, this.region, this.accelerator = AlprAccelerator.gpu});

  final double? detectionThreshold;
  final double? ocrThreshold;
  final BoundingBox? region;
  final AlprAccelerator accelerator;

  Map<String, Object?> toMap() => {
        'detectionThreshold': detectionThreshold,
        'ocrThreshold': ocrThreshold,
        'region': region?.toMap(),
        'accelerator': accelerator.name,
      };
}

class AlprOverlayStyle {
  const AlprOverlayStyle({
    this.boxColor,
    this.boxBorderWidth,
    this.boxCornerRadius,
    this.labelBackgroundColor,
    this.labelTextColor,
    this.labelFontSize,
    this.showLabel,
    this.showPlate,
    this.showCountry,
    this.showConfidence,
  });

  final Color? boxColor;
  final double? boxBorderWidth;
  final double? boxCornerRadius;
  final Color? labelBackgroundColor;
  final Color? labelTextColor;
  final double? labelFontSize;
  final bool? showLabel;
  final bool? showPlate;
  final bool? showCountry;
  final bool? showConfidence;

  Map<String, Object?> toMap() => {
        'boxColor': boxColor?.toARGB32(),
        'boxBorderWidth': boxBorderWidth,
        'boxCornerRadius': boxCornerRadius,
        'labelBackgroundColor': labelBackgroundColor?.toARGB32(),
        'labelTextColor': labelTextColor?.toARGB32(),
        'labelFontSize': labelFontSize,
        'showLabel': showLabel,
        'showPlate': showPlate,
        'showCountry': showCountry,
        'showConfidence': showConfidence,
      };
}

enum AlprErrorCode {
  licenseRequired('ERR_LICENSE_REQUIRED'),
  licenseInvalid('ERR_LICENSE_INVALID'),
  modelLoad('ERR_MODEL_LOAD'),
  camera('ERR_CAMERA'),
  file('ERR_FILE');

  const AlprErrorCode(this.value);
  final String value;

  static AlprErrorCode from(String? value) =>
      AlprErrorCode.values.firstWhere((code) => code.value == value, orElse: () => AlprErrorCode.camera);
}

class AlprException implements Exception {
  const AlprException(this.code, this.message);

  final AlprErrorCode code;
  final String message;

  @override
  String toString() => 'AlprException(${code.value}): $message';
}

enum CameraPermission { granted, denied, undetermined }
