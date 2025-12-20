#!/bin/bash

# Quick run script - builds and runs with production API URL

echo "🚀 Quick Run - VoxaNote with Production API"
echo "============================================="
echo ""

cd "$(dirname "$0")"

API_URL="https://voxanote-production.up.railway.app"

echo "🌐 Using API URL: $API_URL"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    echo ""
    echo "Please either:"
    echo "   1. Add Flutter to your PATH, or"
    echo "   2. Use Xcode: open ios/Runner.xcworkspace"
    exit 1
fi

echo "🔨 Building and running..."
echo ""

# Run with hot reload support
flutter run --dart-define=API_BASE_URL="$API_URL"
