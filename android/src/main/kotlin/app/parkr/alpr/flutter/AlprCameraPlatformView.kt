package app.parkr.alpr.flutter

import android.content.Context
import android.view.View
import app.parkr.alpr.AlprAccelerator
import app.parkr.alpr.AlprCameraView
import app.parkr.alpr.AlprCameraViewListener
import app.parkr.alpr.AlprError
import app.parkr.alpr.AlprPlate
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AlprCameraViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    @Suppress("UNCHECKED_CAST")
    return AlprCameraPlatformView(context, MethodChannel(messenger, "${FlutterAlprPlugin.VIEW_TYPE}/$viewId"), args as? Map<String, Any?>)
  }
}

class AlprCameraPlatformView(context: Context, private val channel: MethodChannel, props: Map<String, Any?>?) :
  PlatformView, AlprCameraViewListener {
  private val camera = AlprCameraView(context)

  init {
    camera.listener = this
    props?.let(::apply)
    channel.setMethodCallHandler { call, result ->
      if (call.method == "update") {
        @Suppress("UNCHECKED_CAST")
        apply(call.arguments as Map<String, Any?>)
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }

  private fun apply(props: Map<String, Any?>) {
    camera.throttle = (props["throttle"] as? Number)?.toLong() ?: 200L
    camera.showFps = props["showFps"] as? Boolean ?: false
    camera.showOverlay = props["showOverlay"] as? Boolean ?: true
    camera.mockImage = props["mockImage"] as? String
    camera.torch = props["torch"] as? Boolean ?: false
    camera.zoom = (props["zoom"] as? Number)?.toFloat() ?: 1f
    @Suppress("UNCHECKED_CAST")
    camera.scanRegion = (props["scanRegion"] as? Map<String, Any?>)?.let(::boundingBox)
    camera.showScanRegion = props["showScanRegion"] as? Boolean ?: true
    @Suppress("UNCHECKED_CAST")
    camera.overlayStyle = (props["overlayStyle"] as? Map<String, Any?>)?.let(::overlayStyle)
    camera.detectionThreshold = (props["detectionThreshold"] as? Number)?.toFloat()
    camera.ocrThreshold = (props["ocrThreshold"] as? Number)?.toFloat()
    camera.accelerator = AlprAccelerator.from(props["accelerator"] as? String)
    camera.recognizesPlates = props["recognizesPlates"] as? Boolean ?: false
    camera.scansPlates = props["scansPlates"] as? Boolean ?: false
    camera.isActive = props["isActive"] as? Boolean ?: true
  }

  override fun getView(): View = camera

  override fun dispose() {
    channel.setMethodCallHandler(null)
    camera.isActive = false
    camera.listener = null
  }

  override fun onPlatesRaw(view: AlprCameraView, plates: List<AlprPlate>, frameWidth: Int, frameHeight: Int) =
    send("onPlatesRaw", mapOf("plates" to plates.map(::plateMap), "frameWidth" to frameWidth, "frameHeight" to frameHeight))

  override fun onPlates(view: AlprCameraView, plates: List<AlprPlate>, frameWidth: Int, frameHeight: Int) =
    send("onPlates", mapOf("plates" to plates.map(::plateMap), "frameWidth" to frameWidth, "frameHeight" to frameHeight))

  override fun onPlate(view: AlprCameraView, plate: AlprPlate) = send("onPlate", mapOf("plate" to plateMap(plate)))

  override fun onScan(view: AlprCameraView, plate: AlprPlate) = send("onScan", mapOf("plate" to plateMap(plate)))

  override fun onError(view: AlprCameraView, error: AlprError) =
    send("onError", mapOf("code" to error.code.value, "message" to (error.message ?: "")))

  private fun send(method: String, arguments: Map<String, Any?>) {
    camera.post { channel.invokeMethod(method, arguments) }
  }
}
