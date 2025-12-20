#!/bin/bash

# Quick fix script to regenerate package-lock.json and deploy

echo "🔧 Fixing package-lock.json for Railway deployment"
echo ""

cd server

# Find npm
NPM_CMD=""
if command -v npm &> /dev/null; then
    NPM_CMD="npm"
elif [ -f "/usr/local/bin/npm" ]; then
    NPM_CMD="/usr/local/bin/npm"
elif [ -f "/opt/homebrew/bin/npm" ]; then
    NPM_CMD="/opt/homebrew/bin/npm"
else
    echo "❌ npm not found!"
    echo ""
    echo "Please install Node.js/npm, then run:"
    echo "  cd server"
    echo "  npm install"
    echo "  cd .."
    echo "  git add server/package-lock.json"
    echo "  git commit -m 'Fix: Regenerate package-lock.json'"
    echo "  git push"
    exit 1
fi

echo "✅ Found npm: $NPM_CMD"
echo ""
echo "📦 Running npm install to regenerate package-lock.json..."
$NPM_CMD install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ package-lock.json regenerated!"
    echo ""
    echo "📤 Committing and pushing..."
    cd ..
    git add server/package-lock.json
    git commit -m "Fix: Regenerate package-lock.json with npm install"
    git push
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Changes pushed to GitHub!"
        echo ""
        echo "🚀 Next steps:"
        echo "   1. Go to Railway dashboard"
        echo "   2. Click 'Redeploy' or wait for auto-deploy"
        echo "   3. The build should now succeed!"
    else
        echo ""
        echo "⚠️  Push failed. Run manually: git push"
    fi
else
    echo ""
    echo "❌ npm install failed. Check errors above."
    exit 1
fi
