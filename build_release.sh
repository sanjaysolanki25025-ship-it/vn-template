#!/bin/bash

echo "What would you like to do?"
echo "1) Flutter Clean + Pub Get"
echo "2) Flutter Clean + Pub Get + Build Release AppBundle"
echo "3) Exit"
read -p "Enter your choice (1, 2, or 3): " choice

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
    ;;
  3)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "❌ Invalid choice! Please enter 1, 2, or 3."
    ;;
esac
