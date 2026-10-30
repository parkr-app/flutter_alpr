import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'types.dart';

const _viewType = 'app.parkr.alpr/camera';

typedef PlatesCallback = void Function(List<DetectedPlate> plates, FrameInfo frame);
typedef PlateCallback = void Function(DetectedPlate plate);

/// Live camera preview that reads license plates.
class AlprCameraView extends StatefulWidget {
  const AlprCameraView({
    super.key,
    this.isActive = true,
    this.throttle = 200,
    this.showFps = false,
    this.showOverlay = true,
    this.mockImage,
    this.torch = false,
    this.zoom = 1,
    this.scanRegion,
    this.showScanRegion = true,
    this.overlayStyle,
    this.detectionThreshold,
    this.ocrThreshold,
    this.accelerator = AlprAccelerator.gpu,
    this.onPlatesRaw,
    this.onPlates,
    this.onPlate,
    this.onScan,
    this.onError,
  });

  final bool isActive;

  /// Minimum time between `onPlates` callbacks, in milliseconds.
  final int throttle;
  final bool showFps;
  final bool showOverlay;

  /// Path of an image to scan instead of the camera, for simulators and tests.
  final String? mockImage;
  final bool torch;
  final double zoom;
  final BoundingBox? scanRegion;
  final bool showScanRegion;
  final AlprOverlayStyle? overlayStyle;
  final double? detectionThreshold;
  final double? ocrThreshold;
  final AlprAccelerator accelerator;

  /// Every plate read in the current frame, unsmoothed.
  final PlatesCallback? onPlatesRaw;

  /// Confirmed plates in view, with consensus text and smoothed boxes.
  final PlatesCallback? onPlates;

  /// Each plate once, when several frames agree. For continuous scanning. PRO.
  final PlateCallback? onPlate;

  /// One plate per activation, once the reads are certain. For scanning a single plate. PRO.
  final PlateCallback? onScan;
  final void Function(AlprException error)? onError;

  @override
  State<AlprCameraView> createState() => _AlprCameraViewState();
}

class _AlprCameraViewState extends State<AlprCameraView> {
  MethodChannel? _channel;

  Map<String, Object?> get _props => {
        'isActive': widget.isActive,
        'throttle': widget.throttle,
        'showFps': widget.showFps,
        'showOverlay': widget.showOverlay,
        'mockImage': widget.mockImage,
        'torch': widget.torch,
        'zoom': widget.zoom,
        'scanRegion': widget.scanRegion?.toMap(),
        'showScanRegion': widget.showScanRegion,
        'overlayStyle': widget.overlayStyle?.toMap(),
        'detectionThreshold': widget.detectionThreshold,
        'ocrThreshold': widget.ocrThreshold,
        'accelerator': widget.accelerator.name,
        'recognizesPlates': widget.onPlate != null,
        'scansPlates': widget.onScan != null,
      };

  @override
  void didUpdateWidget(AlprCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel?.invokeMethod<void>('update', _props);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onCreated(int id) {
    final channel = MethodChannel('$_viewType/$id');
    channel.setMethodCallHandler(_handle);
    _channel = channel;
  }

  Future<void> _handle(MethodCall call) async {
    final args = call.arguments as Map<Object?, Object?>;
    switch (call.method) {
      case 'onPlatesRaw':
      case 'onPlates':
        final callback = call.method == 'onPlates' ? widget.onPlates : widget.onPlatesRaw;
        if (callback == null) return;
        final plates = [for (final p in args['plates'] as List<Object?>) DetectedPlate.fromMap(p as Map<Object?, Object?>)];
        callback(plates, FrameInfo(
          frameWidth: (args['frameWidth'] as num).toDouble(),
          frameHeight: (args['frameHeight'] as num).toDouble(),
        ));
      case 'onPlate':
        widget.onPlate?.call(DetectedPlate.fromMap(args['plate'] as Map<Object?, Object?>));
      case 'onScan':
        widget.onScan?.call(DetectedPlate.fromMap(args['plate'] as Map<Object?, Object?>));
      case 'onError':
        widget.onError?.call(AlprException(AlprErrorCode.from(args['code'] as String?), args['message'] as String? ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = _props;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Hybrid composition: the camera preview is a SurfaceView, which texture-based platform views don't show reliably.
        return PlatformViewLink(
          viewType: _viewType,
          surfaceFactory: (context, controller) => AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
          onCreatePlatformView: (params_) {
            return PlatformViewsService.initExpensiveAndroidView(
              id: params_.id,
              viewType: _viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: params,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params_.onFocusChanged(true),
            )
              ..addOnPlatformViewCreatedListener(params_.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(_onCreated)
              ..create();
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onCreated,
        );
      default:
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onError?.call(
              const AlprException(AlprErrorCode.camera, 'flutter_alpr supports iOS and Android only.'),
            ));
        return const SizedBox.expand();
    }
  }
}
