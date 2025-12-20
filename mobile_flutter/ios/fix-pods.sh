#!/bin/bash

# Fix CocoaPods Manifest.lock issue

echo "🔧 Fixing CocoaPods dependencies..."
echo ""

cd "$(dirname "$0")"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods is not installed or not in your PATH"
    echo ""
    echo "Please run this command first:"
    echo "   sudo gem install cocoapods"
    echo ""
    echo "After installing, run this script again."
    exit 1
fi

echo "✅ CocoaPods found: $(pod --version)"
echo ""

# Clean and reinstall
echo "🧹 Cleaning old Pods..."
rm -rf Pods Podfile.lock

echo "📥 Installing CocoaPods dependencies..."
pod install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! CocoaPods dependencies installed."
    echo ""
    echo "📋 Next steps:"
    echo "   1. Close Xcode if it's open"
    echo "   2. Reopen the workspace:"
    echo "      cd .."
    echo "      open ios/Runner.xcworkspace"
    echo "   3. Build and run in Xcode"
else
    echo ""
    echo "❌ pod install failed. Please check the errors above."
    exit 1
fi
