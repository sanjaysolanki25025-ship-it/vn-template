#!/bin/bash

echo "What would you like to do?"
echo "1) Flutter Clean + Pub Get"
echo "2) Flutter Clean + Pub Get + Build Release AppBundle (.aab)"
echo "3) Flutter Clean + Pub Get + Build Release APK (.apk)"
echo "4) Flutter Clean + Pub Get + Build Both (AppBundle + APK)"
echo "5) Exit"
read -p "Enter your choice (1, 2, 3, 4, or 5): " choice

case $choice in
  1)
    echo "🧹 Cleaning project..."
    flutter clean
    echo "📦 Getting packages..."
    flutter pub get
    echo "✅ Done!"
    ;;
  2)
    echo "🧹 Cleaning project..."
    flutter clean
    echo "📦 Getting packages..."
    flutter pub get
    echo "🚀 Building release appbundle with Next Gen SDK..."
    flutter build appbundle --release --dart-define USE_NEXT_GEN_SDK=true
    echo "✅ Build complete!"
    echo "📍 AppBundle: build/app/outputs/bundle/release/app-release.aab"
    ;;
  3)
    echo "🧹 Cleaning project..."
    flutter clean
    echo "📦 Getting packages..."
    flutter pub get
    echo "🚀 Building release APK with Next Gen SDK..."
    flutter build apk --release --dart-define USE_NEXT_GEN_SDK=true
    echo "✅ Build complete!"
    echo "📍 APK: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  4)
    echo "🧹 Cleaning project..."
    flutter clean
    echo "📦 Getting packages..."
    flutter pub get
    echo "🚀 Building release AppBundle with Next Gen SDK..."
    flutter build appbundle --release --dart-define USE_NEXT_GEN_SDK=true
    echo "🚀 Building release APK with Next Gen SDK..."
    flutter build apk --release --dart-define USE_NEXT_GEN_SDK=true
    echo "✅ Both Builds complete!"
    echo "📍 AppBundle: build/app/outputs/bundle/release/app-release.aab"
    echo "📍 APK: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  5)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "❌ Invalid choice! Please enter 1, 2, 3, 4, or 5."
    ;;
esac
