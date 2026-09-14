#!/bin/bash
set -e

echo "================================================="
echo "  Fleet Rentals - Flutter Web Build for Vercel"
echo "================================================="

# Install Flutter if not present in environment
if ! command -v flutter &> /dev/null
then
    echo "Flutter not detected in PATH. Downloading Flutter SDK (stable)..."
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
