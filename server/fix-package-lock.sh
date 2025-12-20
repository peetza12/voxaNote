#!/bin/bash

# Script to fix package-lock.json by running npm install
# This ensures package.json and package-lock.json are in sync

echo "🔧 Fixing package-lock.json..."
echo ""

cd "$(dirname "$0")"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found in PATH"
    echo ""
    echo "Please run this command manually:"
    echo "  cd server"
    echo "  npm install"
    echo "  git add package-lock.json"
    echo "  git commit -m 'Fix: Regenerate package-lock.json'"
    echo "  git push"
    exit 1
fi

echo "📦 Running npm install to sync package-lock.json..."
npm install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ package-lock.json updated!"
    echo ""
    echo "📤 Committing changes..."
    git add package-lock.json
    git commit -m "Fix: Regenerate package-lock.json with npm install"
    git push
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Changes pushed to GitHub!"
        echo "   Railway should now be able to deploy successfully."
    else
        echo ""
        echo "⚠️  Changes committed locally but push failed."
        echo "   Run: git push"
    fi
else
    echo ""
    echo "❌ npm install failed. Check errors above."
    exit 1
fi
