import AlprKit
import Flutter
import UIKit

final class AlprCameraViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let channel = FlutterMethodChannel(name: "\(FlutterAlprPlugin.viewType)/\(viewId)", binaryMessenger: messenger)
    return AlprCameraPlatformView(frame: frame, channel: channel, props: args as? [String: Any])
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

final class AlprCameraPlatformView: NSObject, FlutterPlatformView, AlprCameraViewDelegate {
  private let camera: AlprCameraView
  private let channel: FlutterMethodChannel

  init(frame: CGRect, channel: FlutterMethodChannel, props: [String: Any]?) {
    camera = AlprCameraView(frame: frame)
    self.channel = channel
    super.init()
    camera.clipsToBounds = true
    camera.delegate = self
    if let props { apply(props) }
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "update", let props = call.arguments as? [String: Any] else {
        return result(FlutterMethodNotImplemented)
      }
      self?.apply(props)
      result(nil)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
    camera.isActive = false
  }

  func view() -> UIView { camera }

  private func apply(_ props: [String: Any]) {
    func value<T>(_ key: String) -> T? { props[key] as? T }
    camera.throttle = value("throttle") as Double? ?? (value("throttle") as Int?).map(Double.init) ?? 200
    camera.showFps = value("showFps") ?? false
    camera.showOverlay = value("showOverlay") ?? true
    camera.mockImage = value("mockImage")
    camera.torch = value("torch") ?? false
    camera.zoom = value("zoom") ?? 1
    camera.scanRegion = (value("scanRegion") as [String: Any]?).map(rect)
    camera.showScanRegion = value("showScanRegion") ?? true
    camera.overlayStyle = (value("overlayStyle") as [String: Any]?).map(overlayStyle)
    camera.detectionThreshold = (value("detectionThreshold") as Double?).map(Float.init)
    camera.ocrThreshold = (value("ocrThreshold") as Double?).map(Float.init)
    camera.accelerator = (value("accelerator") as String?).flatMap(AlprAccelerator.init(rawValue:)) ?? .gpu
    camera.recognizesPlates = value("recognizesPlates") ?? false
    camera.scansPlates = value("scansPlates") ?? false
    camera.isActive = value("isActive") ?? true
  }

  private func send(_ method: String, _ arguments: [String: Any]) {
    DispatchQueue.main.async { self.channel.invokeMethod(method, arguments: arguments) }
  }

  private func platesEvent(_ plates: [AlprPlate], _ frameSize: CGSize) -> [String: Any] {
    ["plates": plates.map(plateMap), "frameWidth": Double(frameSize.width), "frameHeight": Double(frameSize.height)]
  }

  func alprCameraView(_ view: AlprCameraView, didDetectRaw plates: [AlprPlate], frameSize: CGSize) {
    send("onPlatesRaw", platesEvent(plates, frameSize))
  }

  func alprCameraView(_ view: AlprCameraView, didDetect plates: [AlprPlate], frameSize: CGSize) {
    send("onPlates", platesEvent(plates, frameSize))
  }

  func alprCameraView(_ view: AlprCameraView, didRecognize plate: AlprPlate) {
    send("onPlate", ["plate": plateMap(plate)])
  }

  func alprCameraView(_ view: AlprCameraView, didScan plate: AlprPlate) {
    send("onScan", ["plate": plateMap(plate)])
  }

  func alprCameraView(_ view: AlprCameraView, didFailWith error: AlprError) {
    send("onError", ["code": error.code.rawValue, "message": error.message])
  }
}
