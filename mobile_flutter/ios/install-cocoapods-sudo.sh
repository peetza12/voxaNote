#!/bin/bash

# Script to install CocoaPods with sudo (requires password)

echo "🔧 Installing CocoaPods..."
echo ""
echo "This will require your password for sudo."
echo ""

cd "$(dirname "$0")"

# Install CocoaPods system-wide (requires sudo)
sudo gem install cocoapods

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CocoaPods installed successfully!"
    echo ""
    echo "📥 Running pod install..."
    pod install
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Success! All dependencies installed."
        echo ""
        echo "📋 Next steps:"
        echo "   1. Close Xcode if it's open"
        echo "   2. Reopen the workspace:"
        echo "      cd .."
        echo "      open ios/Runner.xcworkspace"
        echo "   3. Build and run in Xcode"
    else
        echo ""
        echo "❌ pod install failed. Check errors above."
        exit 1
    fi
else
    echo ""
    echo "❌ CocoaPods installation failed."
    echo "You may need to update Ruby or use a different installation method."
    exit 1
fi
