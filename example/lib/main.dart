import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alpr/flutter_alpr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Alpr.loadModels();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: ScanScreen()));
}

/// Simulators and emulators have no camera, so debug builds scan a bundled photo instead.
Future<String> bundledPhotoPath() async {
  final bytes = await rootBundle.load('assets/plate-1.png');
  final file = File('${Directory.systemTemp.path}/alpr-example-plate-1.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file.path;
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraPermission? permission;
  String? mockImage;
  bool ready = false;
  List<DetectedPlate> plates = const [];
  final List<String> recognized = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  Future<void> _setUp() async {
    final status = await Alpr.requestCameraPermission();
    setState(() {
      permission = status;
      ready = true;
    });
  }

  Future<void> _onError(AlprException value) async {
    if (value.code == AlprErrorCode.camera && !kReleaseMode && mockImage == null) {
      final path = await bundledPhotoPath();
      setState(() => mockImage = path);
      return;
    }
    setState(() => error = value.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !ready
          ? const SizedBox.shrink()
          : permission != CameraPermission.granted
              ? const Center(child: Text('Allow camera access in Settings.', style: TextStyle(color: Colors.white)))
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    AlprCameraView(
                      mockImage: mockImage,
                      showFps: true,
                      onPlates: (value, _) => setState(() => plates = value),
                      onPlate: (plate) => setState(() => recognized.insert(0, plate.plate)),
                      onError: _onError,
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 32,
                      child: _Results(plates: plates, recognized: recognized, error: error),
                    ),
                  ],
                ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.plates, required this.recognized, required this.error});

  final List<DetectedPlate> plates;
  final List<String> recognized;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final lines = [
      ?error,
      if (plates.isEmpty) 'Point the camera at a license plate.',
      for (final plate in plates) '${plate.plate}  ${plate.countryCode ?? plate.country}',
      if (recognized.isNotEmpty) 'Recognized: ${recognized.take(5).join(', ')}',
    ];
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(lines.join('\n'), style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
