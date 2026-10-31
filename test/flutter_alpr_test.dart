import 'package:flutter/services.dart';
import 'package:flutter_alpr/flutter_alpr.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('app.parkr.alpr');

const _plate = {
  'plate': 'EL11788',
  'ocrConfidence': 0.98,
  'detectionConfidence': 0.9,
  'bbox': {'x': 0.1, 'y': 0.2, 'width': 0.3, 'height': 0.1},
  'country': 'Norway',
  'countryCode': 'NO',
  'countryConfidence': 1,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  void mock(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null));

  test('scanImage sends the config and parses plates', () async {
    mock((_) async => [_plate]);
    final plates = await Alpr.scanImage(
      '/tmp/car.jpg',
      config: const AlprConfig(ocrThreshold: 0.5, region: BoundingBox(x: 0, y: 0.5, width: 1, height: 0.5)),
    );
    expect(calls.single.method, 'scanImage');
    expect(calls.single.arguments, {
      'uri': '/tmp/car.jpg',
      'config': {
        'detectionThreshold': null,
        'ocrThreshold': 0.5,
        'region': {'x': 0.0, 'y': 0.5, 'width': 1.0, 'height': 0.5},
        'accelerator': 'gpu',
      },
    });
    expect(plates.single.plate, 'EL11788');
    expect(plates.single.countryCode, 'NO');
    expect(plates.single.countryConfidence, 1.0);
    expect(plates.single.bbox.width, 0.3);
  });

  test('platform errors become AlprExceptions with their code', () async {
    mock((_) async => throw PlatformException(code: 'ERR_LICENSE_REQUIRED', message: 'needs a license'));
    await expectLater(
      Alpr.scanImage('/tmp/car.jpg'),
      throwsA(isA<AlprException>()
          .having((e) => e.code, 'code', AlprErrorCode.licenseRequired)
          .having((e) => e.message, 'message', 'needs a license')),
    );
  });

  test('camera permission falls back to undetermined', () async {
    mock((call) async => call.method == 'getCameraPermission' ? 'granted' : 'something new');
    expect(await Alpr.getCameraPermission(), CameraPermission.granted);
    expect(await Alpr.requestCameraPermission(), CameraPermission.undetermined);
  });

  test('loadModels and setTelemetryEnabled pass their arguments', () async {
    mock((_) async => null);
    await Alpr.loadModels(accelerator: AlprAccelerator.cpu);
    await Alpr.setTelemetryEnabled(false);
    expect(calls.map((c) => [c.method, c.arguments]), [
      ['loadModels', {'accelerator': 'cpu'}],
      ['setTelemetryEnabled', false],
    ]);
  });

  test('unknown error codes map to camera', () {
    expect(AlprErrorCode.from('ERR_FILE'), AlprErrorCode.file);
    expect(AlprErrorCode.from('nope'), AlprErrorCode.camera);
    expect(AlprErrorCode.from(null), AlprErrorCode.camera);
  });

  test('overlay colors are sent as ARGB integers', () {
    final map = const AlprOverlayStyle(boxColor: Color(0x80FF0000), showLabel: false).toMap();
    expect(map['boxColor'], 0x80FF0000);
    expect(map['showLabel'], false);
    expect(map['labelTextColor'], isNull);
  });

  test('toViewRect maps a box like a scale-to-fill preview', () {
    const frame = FrameInfo(frameWidth: 1000, frameHeight: 500);
    const box = BoundingBox(x: 0.5, y: 0.5, width: 0.1, height: 0.2);
    // A 500x500 view scales the frame to 1000x500 and crops 250 on each side.
    expect(frame.toViewRect(box, const Size(500, 500)), const Rect.fromLTWH(250, 250, 100, 100));
    expect(frame.toViewRect(box, const Size(2000, 1000)), const Rect.fromLTWH(1000, 500, 200, 200));
  });
}
