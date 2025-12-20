#!/bin/bash

# Simplified deployment script - uses Railway web interface
# This will guide you through deployment step by step

echo "🚀 VoxaNote Backend Deployment Guide"
echo "====================================="
echo ""
echo "This script will help you deploy to Railway using their web interface."
echo ""

cd server

# Check if .env exists
if [ -f ".env" ]; then
    echo "✅ Found .env file with configuration"
    echo ""
    echo "📋 Your current configuration:"
    echo ""
    grep -v "^#" .env | grep -v "^$" | grep -v "localhost" | head -10
    echo ""
else
    echo "⚠️  No .env file found"
fi

echo ""
echo "🌐 Step 1: Create Railway Account & Project"
echo "   Go to: https://railway.app"
echo "   Sign up/login with GitHub"
echo "   Click 'New Project' → 'Deploy from GitHub repo'"
echo "   Select your VoxaNote repository"
echo "   Select the 'server' folder as the root"
echo ""
read -p "Press Enter when you've created the project..."

echo ""
echo "🗄️  Step 2: Add PostgreSQL Database"
echo "   In Railway dashboard:"
echo "   Click '+ New' → 'Database' → 'Add PostgreSQL'"
echo ""
read -p "Press Enter when PostgreSQL is added..."

echo ""
echo "🔧 Step 3: Set Environment Variables"
echo "   In Railway dashboard, go to your service → 'Variables'"
echo "   Add these variables:"
echo ""

if [ -f ".env" ]; then
    echo "   From your .env file, you need to set:"
    grep -v "^#" .env | grep -v "^$" | while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        # Skip localhost URLs - these need to be changed
        if [[ "$value" == *"localhost"* ]] || [[ "$value" == *"192.168"* ]]; then
            echo "   ⚠️  $key (needs production value, not: $value)"
        else
            echo "   ✅ $key = $value"
        fi
    done
    echo ""
    echo "   ⚠️  IMPORTANT: Update these for production:"
    echo "      - POSTGRES_URL: Use the value from Railway's PostgreSQL service"
    echo "      - S3_ENDPOINT: Use your production S3 endpoint (e.g., https://s3.amazonaws.com)"
    echo "      - S3_PUBLIC_ENDPOINT: Same as S3_ENDPOINT or your CDN URL"
else
    echo "   Required variables:"
    echo "   - OPENAI_API_KEY=your-openai-key"
    echo "   - S3_ENDPOINT=https://s3.amazonaws.com"
    echo "   - S3_ACCESS_KEY_ID=your-key"
    echo "   - S3_SECRET_ACCESS_KEY=your-secret"
    echo "   - S3_BUCKET=your-bucket-name"
    echo "   - S3_REGION=us-east-1"
    echo "   - POSTGRES_URL=(Railway will provide this automatically)"
fi

echo ""
read -p "Press Enter when environment variables are set..."

echo ""
echo "🚀 Step 4: Deploy"
echo "   Railway will automatically deploy when you:"
echo "   1. Connect your GitHub repo (if not already)"
echo "   2. Set the root directory to 'server'"
echo "   3. Set environment variables"
echo ""
echo "   Or click 'Deploy' button in Railway dashboard"
echo ""
read -p "Press Enter when deployment starts..."

echo ""
echo "⏳ Step 5: Wait for Deployment"
echo "   Watch the deployment logs in Railway"
echo "   Wait for 'Deployed successfully' message"
echo ""
read -p "Press Enter when deployment is complete..."

echo ""
echo "🌐 Step 6: Get Your API URL"
echo "   In Railway dashboard:"
echo "   1. Click on your service"
echo "   2. Go to 'Settings' tab"
echo "   3. Under 'Domains', click 'Generate Domain'"
echo "   4. Copy the domain (e.g., your-app.railway.app)"
echo ""
read -p "Enter your Railway domain (e.g., your-app.railway.app): " DOMAIN

if [ ! -z "$DOMAIN" ]; then
    # Ensure it starts with https://
    if [[ ! "$DOMAIN" =~ ^https?:// ]]; then
        API_URL="https://$DOMAIN"
    else
        API_URL="$DOMAIN"
    fi
    
    echo ""
    echo "🧪 Testing connection..."
    if curl -s "$API_URL/health" > /dev/null 2>&1; then
        echo "   ✅ Server is responding!"
        echo ""
        echo "📋 Your production API URL:"
        echo "   $API_URL"
        echo ""
        echo "💾 Saving to .production-api-url.txt..."
        echo "$API_URL" > ../.production-api-url.txt
        echo "✅ Saved!"
        echo ""
        echo "📱 Next steps:"
        echo "   1. Build iOS: cd mobile_flutter && ./build-ios-release.sh $API_URL"
        echo "   2. Build Android: cd mobile_flutter && ./build-android-release.sh $API_URL"
    else
        echo "   ⚠️  Server not responding yet. It may still be starting."
        echo "   Try again in a minute: curl $API_URL/health"
        echo ""
        echo "   Your API URL: $API_URL"
        echo "$API_URL" > ../.production-api-url.txt
    fi
else
    echo ""
    echo "⚠️  No domain entered. You can get it later from Railway dashboard."
fi

echo ""
echo "✅ Deployment guide complete!"
echo ""
echo "📖 To run database migrations:"
echo "   1. Get POSTGRES_URL from Railway PostgreSQL service"
echo "   2. Run: psql \"\$POSTGRES_URL\" -f migrations/001_init.sql"
