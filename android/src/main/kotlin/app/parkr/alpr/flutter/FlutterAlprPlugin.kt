package app.parkr.alpr.flutter

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import app.parkr.alpr.Alpr
import app.parkr.alpr.AlprAccelerator
import app.parkr.alpr.AlprEngine
import app.parkr.alpr.AlprError
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.Executors

class FlutterAlprPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
  PluginRegistry.RequestPermissionsResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: ActivityPluginBinding? = null
  private var pendingPermission: MethodChannel.Result? = null
  private val executor = Executors.newSingleThreadExecutor()
  private val main = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    Alpr.framework = "flutter"
    Alpr.init(context)
    channel = MethodChannel(binding.binaryMessenger, "app.parkr.alpr")
    channel.setMethodCallHandler(this)
    binding.platformViewRegistry.registerViewFactory(VIEW_TYPE, AlprCameraViewFactory(binding.binaryMessenger))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "loadModels" -> background(result) {
        AlprEngine.loadModels(context, AlprAccelerator.from(call.argument<String>("accelerator")))
        null
      }
      "scanImage" -> background(result) {
        val uri = requireNotNull(call.argument<String>("uri"))
        AlprEngine.scanImage(context, uri, configFrom(call.argument<Map<String, Any?>>("config"))).map(::plateMap)
      }
      "setTelemetryEnabled" -> {
        Alpr.setTelemetryEnabled(call.arguments as Boolean)
        result.success(null)
      }
      "getCameraPermission" -> result.success(permissionState())
      "requestCameraPermission" -> requestPermission(result)
      else -> result.notImplemented()
    }
  }

  private fun background(result: MethodChannel.Result, block: () -> Any?) {
    executor.execute {
      try {
        val value = block()
        main.post { result.success(value) }
      } catch (error: AlprError) {
        main.post { result.error(error.code.value, error.message, null) }
      } catch (error: Exception) {
        main.post { result.error(AlprError.Code.FILE.value, error.message, null) }
      }
    }
  }

  private fun permissionState(): String {
    if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) return "granted"
    val current = activity?.activity ?: return "undetermined"
    val asked = context.getSharedPreferences("app.parkr.alpr.flutter", Context.MODE_PRIVATE).getBoolean("askedCamera", false)
    return if (asked && !ActivityCompat.shouldShowRequestPermissionRationale(current, Manifest.permission.CAMERA)) "denied" else "undetermined"
  }

  private fun requestPermission(result: MethodChannel.Result) {
    val current: Activity = activity?.activity ?: return result.success(permissionState())
    if (permissionState() == "granted") return result.success("granted")
    pendingPermission?.success(permissionState())
    pendingPermission = result
    context.getSharedPreferences("app.parkr.alpr.flutter", Context.MODE_PRIVATE).edit().putBoolean("askedCamera", true).apply()
    ActivityCompat.requestPermissions(current, arrayOf(Manifest.permission.CAMERA), REQUEST_CODE)
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    if (requestCode != REQUEST_CODE) return false
    val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
    pendingPermission?.success(if (granted) "granted" else "denied")
    pendingPermission = null
    return true
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

  override fun onDetachedFromActivity() {
    activity?.removeRequestPermissionsResultListener(this)
    activity = null
  }

  companion object {
    const val VIEW_TYPE = "app.parkr.alpr/camera"
    private const val REQUEST_CODE = 0x41_4c
  }
}
