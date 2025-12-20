#!/bin/bash

# Script to install CocoaPods and run pod install

echo "🔧 Installing CocoaPods dependencies for iOS..."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "📦 CocoaPods not found. Installing..."
    echo ""
    echo "Please run this command in your terminal:"
    echo "  sudo gem install cocoapods"
    echo ""
    echo "Or if you have Homebrew:"
    echo "  brew install cocoapods"
    echo ""
    read -p "Press Enter after installing CocoaPods, or Ctrl+C to cancel..."
fi

# Navigate to iOS directory
cd "$(dirname "$0")"

# Run pod install
echo "📥 Running pod install..."
pod install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CocoaPods dependencies installed successfully!"
    echo "You can now build your iOS app in Xcode."
else
    echo ""
    echo "❌ pod install failed. Please check the error messages above."
    exit 1
fi

