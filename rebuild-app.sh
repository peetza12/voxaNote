#!/bin/bash
# Rebuild the mobile app with the latest fixes

set -e

cd "$(dirname "$0")/mobile_flutter"

echo "🔨 Rebuilding VoxaNote app..."
echo ""

# Try to find Flutter
FLUTTER_CMD=""
if command -v flutter &> /dev/null; then
    FLUTTER_CMD="flutter"
elif [ -f ~/flutter/bin/flutter ]; then
    FLUTTER_CMD="$HOME/flutter/bin/flutter"
elif [ -f ~/.flutter/bin/flutter ]; then
    FLUTTER_CMD="$HOME/.flutter/bin/flutter"
elif [ -f /opt/homebrew/bin/flutter ]; then
    FLUTTER_CMD="/opt/homebrew/bin/flutter"
else
    echo "❌ Flutter not found. Please:"
    echo "   1. Open Xcode"
    echo "   2. Open mobile_flutter/ios/Runner.xcworkspace"
    echo "   3. Product → Clean Build Folder (Shift+Cmd+K)"
    echo "   4. Product → Run (Cmd+R)"
    echo ""
    echo "   OR add Flutter to your PATH and run this script again"
    exit 1
fi

echo "Found Flutter: $FLUTTER_CMD"
echo ""

echo "Cleaning..."
$FLUTTER_CMD clean

echo "Getting dependencies..."
$FLUTTER_CMD pub get

echo ""
echo "✅ Code updated! Now rebuild in Xcode:"
echo "   1. Open Xcode"
echo "   2. Open mobile_flutter/ios/Runner.xcworkspace"
echo "   3. Product → Clean Build Folder (Shift+Cmd+K)"
echo "   4. Product → Run (Cmd+R)"
echo ""
echo "   The fix is already in the code - just rebuild!"
