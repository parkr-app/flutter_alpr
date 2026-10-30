import AlprKit
import UIKit

func plateMap(_ plate: AlprPlate) -> [String: Any] {
  [
    "plate": plate.plate,
    "ocrConfidence": Double(plate.ocrConfidence),
    "detectionConfidence": Double(plate.detectionConfidence),
    "bbox": [
      "x": Double(plate.bbox.origin.x),
      "y": Double(plate.bbox.origin.y),
      "width": Double(plate.bbox.size.width),
      "height": Double(plate.bbox.size.height),
    ],
    "country": plate.country,
    "countryCode": plate.countryCode as Any,
    "countryConfidence": Double(plate.countryConfidence),
  ]
}

func rect(_ map: [String: Any]) -> CGRect {
  func value(_ key: String) -> CGFloat { CGFloat(map[key] as? Double ?? 0) }
  return CGRect(x: value("x"), y: value("y"), width: value("width"), height: value("height"))
}

func alprConfig(_ map: [String: Any]?) -> AlprConfig {
  guard let map else { return AlprConfig() }
  return AlprConfig(
    detectionThreshold: (map["detectionThreshold"] as? Double).map(Float.init),
    ocrThreshold: (map["ocrThreshold"] as? Double).map(Float.init),
    region: (map["region"] as? [String: Any]).map(rect),
    accelerator: (map["accelerator"] as? String).flatMap(AlprAccelerator.init(rawValue:)) ?? .gpu
  )
}

private func color(_ value: Any?) -> UIColor? {
  guard let number = value as? NSNumber else { return nil }
  let argb = UInt32(truncatingIfNeeded: number.int64Value)
  return UIColor(
    red: CGFloat((argb >> 16) & 0xFF) / 255,
    green: CGFloat((argb >> 8) & 0xFF) / 255,
    blue: CGFloat(argb & 0xFF) / 255,
    alpha: CGFloat((argb >> 24) & 0xFF) / 255
  )
}

func overlayStyle(_ map: [String: Any]) -> AlprOverlayStyle {
  var style = AlprOverlayStyle()
  func number(_ key: String) -> CGFloat? { (map[key] as? Double).map { CGFloat($0) } }
  style.boxColor = color(map["boxColor"])
  style.boxBorderWidth = number("boxBorderWidth") ?? style.boxBorderWidth
  style.boxCornerRadius = number("boxCornerRadius") ?? style.boxCornerRadius
  style.labelBackgroundColor = color(map["labelBackgroundColor"])
  style.labelTextColor = color(map["labelTextColor"]) ?? style.labelTextColor
  style.labelFontSize = number("labelFontSize") ?? style.labelFontSize
  style.showLabel = map["showLabel"] as? Bool ?? style.showLabel
  style.showPlate = map["showPlate"] as? Bool ?? style.showPlate
  style.showCountry = map["showCountry"] as? Bool ?? style.showCountry
  style.showConfidence = map["showConfidence"] as? Bool ?? style.showConfidence
  return style
}
