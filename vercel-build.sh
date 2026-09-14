#!/bin/bash
set -e

echo "================================================="
echo "  Fleet Rentals - Flutter Web Build for Vercel"
echo "================================================="

# 1. If pre-built web artifacts already exist, use them directly for instantaneous deployment
if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
    echo "Pre-built Flutter Web production distribution detected in build/web."
    echo "Deploying directly to Vercel CDN - Instant build complete!"
    exit 0
fi

# 2. Fallback: Build from source if pre-built bundle is not present
echo "Pre-built bundle not detected. Building Flutter Web from source..."

if ! command -v flutter &> /dev/null
then
    echo "Downloading Flutter SDK (stable)..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable ./flutter-sdk
    export PATH="$PATH:$(pwd)/flutter-sdk/bin"
else
    echo "Found Flutter in PATH: $(which flutter)"
fi

echo "Flutter version:"
flutter --version

echo "Configuring Flutter for web-only build..."
flutter config --no-enable-windows-desktop --no-enable-linux-desktop --no-enable-macos-desktop

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web in release mode..."
flutter build web --release --no-tree-shake-icons

echo "Build succeeded! Web output generated in build/web."
