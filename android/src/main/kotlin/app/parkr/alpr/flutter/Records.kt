package app.parkr.alpr.flutter

import app.parkr.alpr.AlprAccelerator
import app.parkr.alpr.AlprConfig
import app.parkr.alpr.AlprOverlayStyle
import app.parkr.alpr.AlprPlate
import app.parkr.alpr.BoundingBox

internal fun plateMap(plate: AlprPlate): Map<String, Any?> = mapOf(
  "plate" to plate.plate,
  "ocrConfidence" to plate.ocrConfidence.toDouble(),
  "detectionConfidence" to plate.detectionConfidence.toDouble(),
  "bbox" to mapOf(
    "x" to plate.bbox.x.toDouble(),
    "y" to plate.bbox.y.toDouble(),
    "width" to plate.bbox.width.toDouble(),
    "height" to plate.bbox.height.toDouble(),
  ),
  "country" to plate.country,
  "countryCode" to plate.countryCode,
  "countryConfidence" to plate.countryConfidence.toDouble(),
)

private fun Map<String, Any?>.float(key: String): Float? = (this[key] as? Number)?.toFloat()

internal fun boundingBox(map: Map<String, Any?>) =
  BoundingBox(map.float("x") ?: 0f, map.float("y") ?: 0f, map.float("width") ?: 0f, map.float("height") ?: 0f)

@Suppress("UNCHECKED_CAST")
internal fun configFrom(map: Map<String, Any?>?): AlprConfig {
  if (map == null) return AlprConfig()
  return AlprConfig(
    detectionThreshold = map.float("detectionThreshold"),
    ocrThreshold = map.float("ocrThreshold"),
    region = (map["region"] as? Map<String, Any?>)?.let(::boundingBox),
    accelerator = AlprAccelerator.from(map["accelerator"] as? String),
  )
}

internal fun overlayStyle(map: Map<String, Any?>): AlprOverlayStyle {
  val defaults = AlprOverlayStyle()
  fun color(key: String): Int? = (map[key] as? Number)?.toLong()?.toInt()
  return AlprOverlayStyle(
    boxColor = color("boxColor"),
    boxBorderWidth = map.float("boxBorderWidth") ?: defaults.boxBorderWidth,
    boxCornerRadius = map.float("boxCornerRadius") ?: defaults.boxCornerRadius,
    labelBackgroundColor = color("labelBackgroundColor"),
    labelTextColor = color("labelTextColor") ?: defaults.labelTextColor,
    labelFontSize = map.float("labelFontSize") ?: defaults.labelFontSize,
    showLabel = map["showLabel"] as? Boolean ?: defaults.showLabel,
    showPlate = map["showPlate"] as? Boolean ?: defaults.showPlate,
    showCountry = map["showCountry"] as? Boolean ?: defaults.showCountry,
    showConfidence = map["showConfidence"] as? Boolean ?: defaults.showConfidence,
  )
}
