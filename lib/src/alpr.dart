import 'package:flutter/services.dart';

import 'types.dart';

const _channel = MethodChannel('app.parkr.alpr');

Future<T?> invokeAlpr<T>(String method, [Object? arguments]) async {
  try {
    return await _channel.invokeMethod<T>(method, arguments);
  } on PlatformException catch (error) {
    throw AlprException(AlprErrorCode.from(error.code), error.message ?? error.code);
  }
}

abstract final class Alpr {
  /// Loads the models ahead of time, so the first camera frame or photo is read without a delay.
  static Future<void> loadModels({AlprAccelerator accelerator = AlprAccelerator.gpu}) =>
      invokeAlpr<void>('loadModels', {'accelerator': accelerator.name});

  /// Reads the plates in the image at [path] (a file path or URI). PRO: needs a license key in release builds.
  static Future<List<DetectedPlate>> scanImage(String path, {AlprConfig config = const AlprConfig()}) async {
    final plates = await invokeAlpr<List<Object?>>('scanImage', {'uri': path, 'config': config.toMap()});
    return [for (final plate in plates ?? const []) DetectedPlate.fromMap(plate as Map<Object?, Object?>)];
  }

  static Future<void> setTelemetryEnabled(bool enabled) => invokeAlpr<void>('setTelemetryEnabled', enabled);

  static Future<CameraPermission> getCameraPermission() async =>
      _permission(await invokeAlpr<String>('getCameraPermission'));

  static Future<CameraPermission> requestCameraPermission() async =>
      _permission(await invokeAlpr<String>('requestCameraPermission'));

  static CameraPermission _permission(String? value) =>
      CameraPermission.values.firstWhere((p) => p.name == value, orElse: () => CameraPermission.undetermined);
}
