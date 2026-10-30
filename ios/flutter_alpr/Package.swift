// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "flutter_alpr",
  platforms: [
    .iOS("15.1")
  ],
  products: [
    .library(name: "flutter-alpr", targets: ["flutter_alpr"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "flutter_alpr",
      dependencies: [
        "AlprKit",
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ]
    ),
    // Fetched by scripts/fetch-binaries.sh and shipped in the pub.dev package.
    .binaryTarget(name: "AlprKit", path: "Frameworks/AlprKit.xcframework"),
  ]
)
