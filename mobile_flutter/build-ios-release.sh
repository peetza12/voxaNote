#!/bin/bash

# Build iOS release with production API URL
# Usage: ./build-ios-release.sh [API_URL]
# Example: ./build-ios-release.sh https://your-api.railway.app

API_URL="${1:-https://your-production-api-url.com}"

if [ "$API_URL" = "https://your-production-api-url.com" ]; then
    echo "⚠️  Warning: Using default API URL. Please provide your production API URL:"
    echo "   ./build-ios-release.sh https://your-api.railway.app"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🔨 Building iOS release with API URL: $API_URL"
echo ""

cd "$(dirname "$0")"

flutter clean
flutter build ios --release --dart-define=API_BASE_URL="$API_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ iOS build complete!"
    echo "📦 Archive location: build/ios/archive/Runner.xcarchive"
    echo "🌐 API URL configured: $API_URL"
    echo ""
    echo "Next steps:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Product → Archive"
    echo "3. Distribute to App Store"
else
    echo ""
    echo "❌ Build failed. Check errors above."
    exit 1
fi
