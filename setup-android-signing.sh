#!/bin/bash

# Setup script for Android app signing
# Run this before building for release

set -e

cd "$(dirname "$0")/mobile_flutter/android"

echo "🔐 Setting up Android app signing..."
echo ""

# Check if keystore already exists
if [ -f "voxanote-keystore.jks" ]; then
    echo "⚠️  Keystore already exists. Skipping generation."
    echo "   If you want to create a new one, delete voxanote-keystore.jks first."
    echo ""
else
    echo "📝 Generating new keystore..."
    echo "   You'll be prompted for:"
    echo "   - Keystore password (save this!)"
    echo "   - Key password (can be same as keystore password)"
    echo "   - Your name/company details"
    echo ""
    
    keytool -genkey -v -keystore voxanote-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias voxanote
    
    echo ""
    echo "✅ Keystore created: voxanote-keystore.jks"
    echo ""
fi

# Create key.properties file
if [ -f "key.properties" ]; then
    echo "⚠️  key.properties already exists."
    read -p "   Overwrite? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Keeping existing key.properties"
        exit 0
    fi
fi

echo "📝 Creating key.properties file..."
echo "   You'll need to enter your keystore password:"
echo ""

read -sp "Enter keystore password: " KEYSTORE_PASSWORD
echo ""
read -sp "Enter key password (or press Enter to use same as keystore): " KEY_PASSWORD
echo ""

if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD="$KEYSTORE_PASSWORD"
fi

cat > key.properties << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=voxanote
storeFile=voxanote-keystore.jks
EOF

echo "✅ key.properties created"
echo ""

# Update .gitignore
cd ../..
if [ -f ".gitignore" ]; then
    if ! grep -q "android/key.properties" .gitignore; then
        echo "android/key.properties" >> .gitignore
        echo "✅ Added key.properties to .gitignore"
    fi
    if ! grep -q "android/*.jks" .gitignore; then
        echo "android/*.jks" >> .gitignore
        echo "✅ Added *.jks to .gitignore"
    fi
fi

echo ""
echo "🎉 Android signing setup complete!"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Keep your keystore file (voxanote-keystore.jks) safe!"
echo "   - Save your passwords - you'll need them for all future updates"
echo "   - Never commit the keystore or key.properties to git"
echo ""
echo "Next steps:"
echo "   1. Update android/app/build.gradle.kts with signing config (see DEPLOYMENT_GUIDE.md)"
echo "   2. Run: flutter build appbundle --release"

