#!/bin/bash

# Quick rebuild script - automates the clean/rebuild process

echo "🚀 Quick Rebuild for VoxaNote"
echo "=============================="
echo ""

cd "$(dirname "$0")"

# Check if Xcode is running
if pgrep -x "Xcode" > /dev/null; then
    echo "⚠️  Xcode is running. Please close it first, or press Ctrl+C to cancel."
    echo "   (The script will wait 5 seconds for you to close it...)"
    sleep 5
fi

echo "🧹 Cleaning build artifacts..."
flutter clean 2>/dev/null || echo "   (Flutter clean skipped - Flutter not in PATH)"

# Clean Xcode derived data
echo "🧹 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null
echo "   ✅ Derived data cleaned"

# Clean iOS build folder
echo "🧹 Cleaning iOS build folder..."
rm -rf ios/build 2>/dev/null
rm -rf build/ios 2>/dev/null
echo "   ✅ iOS build cleaned"

echo ""
echo "✅ Clean complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Open Xcode: open ios/Runner.xcworkspace"
echo "   2. Build and run (Cmd+R)"
echo ""
echo "Or if you have Flutter in PATH, you can run directly:"
echo "   flutter run --release"
