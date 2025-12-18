#!/bin/bash
set -e

echo "🍎 Setting up iOS dependencies..."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "📦 Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods already installed"
fi

# Navigate to Flutter project
cd "$(dirname "$0")/mobile_flutter"

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "📥 Getting Flutter dependencies..."
flutter pub get

echo "📦 Installing iOS CocoaPods dependencies..."
cd ios
pod install
cd ..

echo ""
echo "✅ iOS setup complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select your iPhone as the target device"
echo "3. Configure signing in Xcode (Signing & Capabilities tab)"
echo "4. Run the app (Cmd+R)"
echo ""
echo "Or run from terminal:"
echo "flutter run -d <your-iphone-id> --dart-define=API_BASE_URL=http://192.168.5.89:4000"

