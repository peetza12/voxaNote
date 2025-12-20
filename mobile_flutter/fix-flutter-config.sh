#!/bin/bash

# Fix Flutter iOS configuration issues

echo "🔧 Fixing Flutter iOS Configuration"
echo "===================================="
echo ""

cd "$(dirname "$0")"

# Step 1: Clean Flutter build
echo "🧹 Step 1: Cleaning Flutter build..."
flutter clean 2>/dev/null || {
    echo "   ⚠️  Flutter not in PATH. Skipping flutter clean."
    echo "   You'll need to run this manually or use Xcode method."
}

# Step 2: Get Flutter packages
echo ""
echo "📦 Step 2: Getting Flutter packages..."
flutter pub get 2>/dev/null || {
    echo "   ⚠️  Flutter not in PATH. Skipping flutter pub get."
    echo "   You'll need to run this manually."
}

# Step 3: Regenerate iOS configuration
echo ""
echo "🔨 Step 3: Regenerating iOS configuration..."
flutter build ios --no-codesign 2>&1 | tail -10 || {
    echo ""
    echo "   ⚠️  Flutter build failed or Flutter not in PATH."
    echo ""
    echo "   Alternative: Use Xcode method below"
}

echo ""
echo "✅ Configuration should be fixed!"
echo ""
echo "📋 Next steps:"
echo "   1. Open Xcode: open ios/Runner.xcworkspace"
echo "   2. Build and run (Cmd+R)"
