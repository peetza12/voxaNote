#!/bin/bash

# Build Android release with production API URL
# Usage: ./build-android-release.sh [API_URL]
# Example: ./build-android-release.sh https://your-api.railway.app

API_URL="${1:-https://your-production-api-url.com}"

if [ "$API_URL" = "https://your-production-api-url.com" ]; then
    echo "⚠️  Warning: Using default API URL. Please provide your production API URL:"
    echo "   ./build-android-release.sh https://your-api.railway.app"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🔨 Building Android release with API URL: $API_URL"
echo ""

cd "$(dirname "$0")"

flutter clean
flutter build appbundle --release --dart-define=API_BASE_URL="$API_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Android build complete!"
    echo "📦 AAB location: build/app/outputs/bundle/release/app-release.aab"
    echo "🌐 API URL configured: $API_URL"
    echo ""
    echo "Next steps:"
    echo "1. Upload app-release.aab to Google Play Console"
    echo "2. Complete store listing and submit for review"
else
    echo ""
    echo "❌ Build failed. Check errors above."
    exit 1
fi
