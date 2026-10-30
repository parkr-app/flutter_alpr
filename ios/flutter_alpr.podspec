Pod::Spec.new do |s|
  s.name             = "flutter_alpr"
  s.version          = "0.4.0"
  s.summary          = "On-device license plate recognition (ALPR/ANPR) for Flutter."
  s.homepage         = "https://alpr.parkr.app"
  s.license          = { :type => "MIT", :file => "../LICENSE" }
  s.author           = { "Bileier AS" => "post@parkr.app" }
  s.source           = { :path => "." }
  s.source_files     = "flutter_alpr/Sources/flutter_alpr/**/*.swift"
  s.vendored_frameworks = "flutter_alpr/Frameworks/AlprKit.xcframework"
  s.frameworks       = "AVFoundation", "UIKit"
  s.dependency "Flutter"
  s.platform         = :ios, "15.1"
  s.swift_version    = "5.9"
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }
end
