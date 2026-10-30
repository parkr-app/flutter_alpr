# flutter_alpr

On-device license plate recognition (ALPR/ANPR) for Flutter apps on iOS and Android. It wraps AlprKit, the native SDK behind [react-native-alpr](https://github.com/parkr-app/react-native-alpr); one license key works for both.

<p align="center">
  <img src="https://alpr.parkr.app/screenshots/ios-scan-bmw-i3.webp" width="200" alt="iPhone: live scan reading EL 40489">
  <img src="https://alpr.parkr.app/screenshots/ios-photo-tesla-model-s.webp" width="200" alt="iPhone: two Tesla plates read from a photo">
  <img src="https://alpr.parkr.app/screenshots/android-scan-nissan-e-nv200.webp" width="200" alt="Android: live scan reading EL 64433">
  <img src="https://alpr.parkr.app/screenshots/android-photo-nissan-leaf.webp" width="200" alt="Android: EL 15211 read from a photo">
</p>
<p align="center"><sub>Photos: Norsk Elbilforening and Mariordo, <a href="https://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a>, via <a href="https://commons.wikimedia.org/wiki/Category:Electric_vehicle_license_plates_of_Norway">Wikimedia Commons</a>, cropped.</sub></p>

- Fully offline, runs on the device (Core ML on iOS, LiteRT from Google Play services on Android)
- Live camera scanning at 30 FPS with GPU or Neural Engine acceleration
- Plate text, country and bounding box, several plates per frame, [65 countries](#supported-countries)
- Stable results: reads from several frames are combined into one answer, and boxes move smoothly
- One-shot scanning that waits for a certain read instead of taking the first blurry frame
- Recognition in photos

**The basic scanner is free, also in production.** PRO features need a license key in release builds and work without one in development builds. See [Licensing](#licensing) and [alpr.parkr.app](https://alpr.parkr.app).

## Platforms

One license key covers your app on every platform.

| Platform | Package | Repository |
| --- | --- | --- |
| Expo and React Native | `react-native-alpr` on npm | [parkr-app/react-native-alpr](https://github.com/parkr-app/react-native-alpr) |
| iOS (Swift) | `AlprKit` through Swift Package Manager | [parkr-app/alpr-ios](https://github.com/parkr-app/alpr-ios) |
| Android (Kotlin) | `app.parkr:alpr` | [parkr-app/alpr-android](https://github.com/parkr-app/alpr-android) |
| Flutter | `flutter_alpr` on pub.dev | [parkr-app/flutter_alpr](https://github.com/parkr-app/flutter_alpr) |
| Capacitor | `capacitor-alpr`, in development | [parkr-app/capacitor-alpr](https://github.com/parkr-app/capacitor-alpr) |

## Supported countries

🇦🇱 Albania (`AL`), 🇦🇩 Andorra (`AD`), 🇦🇷 Argentina (`AR`), 🇦🇲 Armenia (`AM`), 🇦🇺 Australia (`AU`), 🇦🇹 Austria (`AT`), 🇦🇿 Azerbaijan (`AZ`), 🇧🇭 Bahrain (`BH`), 🇧🇾 Belarus (`BY`), 🇧🇪 Belgium (`BE`), 🇧🇦 Bosnia and Herzegovina (`BA`), 🇧🇷 Brazil (`BR`), 🇧🇬 Bulgaria (`BG`), 🇰🇭 Cambodia (`KH`), 🇨🇦 Canada (`CA`), 🇭🇷 Croatia (`HR`), 🇨🇾 Cyprus (`CY`), 🇨🇿 Czech Republic (`CZ`), 🇩🇰 Denmark (`DK`), 🇪🇪 Estonia (`EE`), 🇫🇮 Finland (`FI`), 🇫🇷 France (`FR`), 🇬🇪 Georgia (`GE`), 🇩🇪 Germany (`DE`), 🇬🇮 Gibraltar (`GI`), 🇬🇷 Greece (`GR`), 🇬🇬 Guernsey (`GG`), 🇭🇺 Hungary (`HU`), 🇮🇸 Iceland (`IS`), 🇮🇩 Indonesia (`ID`), 🇮🇪 Ireland (`IE`), 🇮🇱 Israel (`IL`), 🇮🇹 Italy (`IT`), 🇱🇻 Latvia (`LV`), 🇱🇮 Liechtenstein (`LI`), 🇱🇹 Lithuania (`LT`), 🇱🇺 Luxembourg (`LU`), 🇲🇾 Malaysia (`MY`), 🇲🇹 Malta (`MT`), 🇲🇽 Mexico (`MX`), 🇲🇩 Moldova (`MD`), 🇲🇨 Monaco (`MC`), 🇲🇪 Montenegro (`ME`), 🇳🇱 Netherlands (`NL`), 🇳🇿 New Zealand (`NZ`), 🇲🇰 North Macedonia (`MK`), 🇳🇴 Norway (`NO`), 🇵🇱 Poland (`PL`), 🇵🇹 Portugal (`PT`), 🇶🇦 Qatar (`QA`), 🇷🇴 Romania (`RO`), 🇸🇲 San Marino (`SM`), 🇷🇸 Serbia (`RS`), 🇸🇬 Singapore (`SG`), 🇸🇰 Slovakia (`SK`), 🇸🇮 Slovenia (`SI`), 🇪🇸 Spain (`ES`), 🇸🇪 Sweden (`SE`), 🇨🇭 Switzerland (`CH`), 🇹🇭 Thailand (`TH`), 🇹🇷 Turkey (`TR`), 🇺🇦 Ukraine (`UA`), 🇬🇧 United Kingdom (`GB`), 🇺🇸 United States (`US`), 🇻🇳 Vietnam (`VN`).

## Installation

```sh
flutter pub add flutter_alpr
```

Requires iOS 15.1 and Android 7.0 (API 24).

**iOS:** add `NSCameraUsageDescription` to `ios/Runner/Info.plist`, and set `platform :ios, '15.1'` in `ios/Podfile`.

**Android:** the plugin adds the `CAMERA` permission and the `https://alpr.parkr.app/maven` repository for the `app.parkr:alpr` SDK. If your `settings.gradle` sets `RepositoriesMode.FAIL_ON_PROJECT_REPOS`, add that repository there instead.

## Usage

```dart
import 'package:flutter_alpr/flutter_alpr.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraPermission? permission;

  @override
  void initState() {
    super.initState();
    Alpr.requestCameraPermission().then((value) => setState(() => permission = value));
  }

  @override
  Widget build(BuildContext context) {
    if (permission != CameraPermission.granted) return const Center(child: Text('Camera access needed'));
    return AlprCameraView(
      onPlates: (plates, frame) => debugPrint(plates.map((p) => p.plate).join(', ')),
      onScan: (plate) => Navigator.pop(context, plate.plate), // PRO
    );
  }
}
```

Read plates in a photo (PRO):

```dart
final plates = await Alpr.scanImage('/path/to/photo.jpg');
```

Call `Alpr.loadModels()` early, for example in `main()`, so the first frame is read without a delay.

## Licensing

| | Development builds | Release builds without a key | Release builds with a key |
| --- | --- | --- | --- |
| Live scanning, `onPlates`, `onPlatesRaw`, default overlay | ✓ | ✓ | ✓ |
| PRO features | ✓ | Off | ✓ |

Development builds are debug builds, simulators and emulators, TestFlight and ad-hoc builds. Without a key, release builds fall back quietly and never crash: the scanner runs on the CPU with default settings, `onPlate` and `onScan` don't fire, torch and zoom stay off, and `scanImage` throws `AlprException` with `AlprErrorCode.licenseRequired`.

Get a key at [alpr.parkr.app](https://alpr.parkr.app). A key is bound to your app ids and works on every platform and framework. Add it as `AlprLicenseKey` (String) in `ios/Runner/Info.plist`, and in `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<meta-data android:name="app.parkr.alpr.LICENSE_KEY" android:value="eyJ2Ijox..." />
```

## Telemetry

At most once a day per device, the SDK sends a small anonymous report to `alpr.parkr.app`: app id and version, platform, OS and SDK versions, build type, license state and the names of disabled PRO features. It never contains device or user identifiers, images or plate data. It is on by default without a license and off by default with one. Turn it off with `Alpr.setTelemetryEnabled(false)`.

## API

### `AlprCameraView`

| Parameter | Default | |
| --- | --- | --- |
| `isActive` | `true` | Runs the camera |
| `throttle` | `200` | Milliseconds between `onPlates` callbacks. PRO to change |
| `showOverlay` | `true` | Draws boxes and labels. PRO to hide |
| `showFps` | `false` | Shows the frame rate |
| `torch`, `zoom` | `false`, `1` | PRO |
| `scanRegion`, `showScanRegion` | full frame, `true` | Normalized region to scan. PRO |
| `overlayStyle` | | `AlprOverlayStyle` for box and label colors and sizes. PRO |
| `detectionThreshold`, `ocrThreshold` | `0.4`, `0.3` | PRO |
| `accelerator` | `AlprAccelerator.gpu` | PRO; the CPU is used without a key |
| `mockImage` | | Image path to scan instead of the camera, for simulators |
| `onPlatesRaw(plates, frame)` | | Every plate read in the frame, unsmoothed |
| `onPlates(plates, frame)` | | Confirmed plates in view, smoothed |
| `onPlate(plate)` | | Each plate once, when several frames agree. PRO |
| `onScan(plate)` | | One certain plate per activation. PRO |
| `onError(error)` | | `AlprException` with a `code` and `message` |

Use `frame.toViewRect(plate.bbox, size)` to map a plate's normalized box to the view.

### `Alpr`

- `loadModels({accelerator})`
- `scanImage(path, {config})` → `List<DetectedPlate>` (PRO)
- `getCameraPermission()`, `requestCameraPermission()` → `CameraPermission`
- `setTelemetryEnabled(enabled)`

`DetectedPlate` has `plate`, `ocrConfidence`, `detectionConfidence`, `bbox`, `country`, `countryCode` and `countryConfidence`.

## Example app

[example](example) scans with the camera on a device and with a bundled photo on simulators and emulators:

```sh
cd example && flutter run
```

## License

The Dart and platform code in this repository is MIT licensed. The bundled AlprKit native SDK is licensed under the [Parkr ALPR SDK License Agreement](SDK-LICENSE.md). Bundled models: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
