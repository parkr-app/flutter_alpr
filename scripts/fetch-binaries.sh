#!/usr/bin/env bash
# Downloads AlprKit.xcframework for the version in pubspec.yaml into ios/flutter_alpr/Frameworks.
set -euo pipefail

cd "$(dirname "$0")/.."
version=$(sed -n 's/^version: //p' pubspec.yaml)
base="${ALPR_BASE_URL:-https://alpr.parkr.app}"
zip="AlprKit-$version.xcframework.zip"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$base/sdk/ios/$version/$zip" -o "$tmp/$zip"
expected=$(curl -fsSL "$base/sdk/ios/$version/$zip.sha256" | awk '{print $1}')
actual=$(shasum -a 256 "$tmp/$zip" | awk '{print $1}')
[ "$expected" = "$actual" ] || { echo "Checksum mismatch for $zip" >&2; exit 1; }

rm -rf ios/flutter_alpr/Frameworks/AlprKit.xcframework
mkdir -p ios/flutter_alpr/Frameworks
unzip -q "$tmp/$zip" -x "__MACOSX/*" -d ios/flutter_alpr/Frameworks
echo "AlprKit $version in ios/flutter_alpr/Frameworks"
