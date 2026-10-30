import AlprKit
import AVFoundation
import Flutter
import UIKit

public final class FlutterAlprPlugin: NSObject, FlutterPlugin {
  static let viewType = "app.parkr.alpr/camera"
  private let queue = DispatchQueue(label: "app.parkr.alpr.flutter", qos: .userInitiated)

  public static func register(with registrar: FlutterPluginRegistrar) {
    Alpr.framework = "flutter"
    let instance = FlutterAlprPlugin()
    let channel = FlutterMethodChannel(name: "app.parkr.alpr", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(AlprCameraViewFactory(messenger: registrar.messenger()), withId: viewType)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "loadModels":
      background(result) {
        try AlprEngine.shared.loadModels(accelerator: AlprAccelerator(rawValue: args?["accelerator"] as? String ?? "") ?? .gpu)
        return nil
      }
    case "scanImage":
      background(result) {
        let uri = args?["uri"] as? String ?? ""
        guard let url = uri.hasPrefix("/") ? URL(fileURLWithPath: uri) : URL(string: uri) else {
          throw AlprError(.file, "Invalid image URI \(uri)")
        }
        return try AlprEngine.shared.scanImage(contentsOf: url, config: alprConfig(args?["config"] as? [String: Any]))
          .map(plateMap)
      }
    case "setTelemetryEnabled":
      Alpr.setTelemetryEnabled(call.arguments as? Bool ?? true)
      result(nil)
    case "getCameraPermission":
      result(permissionState())
    case "requestCameraPermission":
      AVCaptureDevice.requestAccess(for: .video) { _ in
        DispatchQueue.main.async { result(self.permissionState()) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func background(_ result: @escaping FlutterResult, _ body: @escaping () throws -> Any?) {
    queue.async {
      do {
        let value = try body()
        DispatchQueue.main.async { result(value) }
      } catch let error as AlprError {
        DispatchQueue.main.async { result(FlutterError(code: error.code.rawValue, message: error.message, details: nil)) }
      } catch {
        DispatchQueue.main.async { result(FlutterError(code: AlprError.Code.file.rawValue, message: error.localizedDescription, details: nil)) }
      }
    }
  }

  private func permissionState() -> String {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: return "granted"
    case .notDetermined: return "undetermined"
    default: return "denied"
    }
  }
}
