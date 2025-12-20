#!/bin/bash
# Automated setup script for Railway Storage Bucket
# This script helps you set up S3 storage on Railway with minimal steps

set -e

echo "🚀 Railway Storage Setup - Automated"
echo "======================================"
echo ""
echo "Railway Storage Buckets are FREE and built-in!"
echo ""
echo "STEP 1: Create the bucket (2 clicks):"
echo "  1. Go to: https://railway.app/project"
echo "  2. Click your project name"
echo "  3. Click '+ New' → 'Bucket'"
echo "  4. Name it: voxanote-audio"
echo "  5. Click 'Create'"
echo ""
echo "STEP 2: Get credentials (1 click):"
echo "  1. Click on the bucket you just created"
echo "  2. Click the 'Credentials' tab"
echo "  3. Copy these values:"
echo "     - ENDPOINT"
echo "     - ACCESS_KEY_ID"
echo "     - SECRET_ACCESS_KEY"
echo "     - BUCKET (the full bucket name)"
echo ""
read -p "Press Enter when you have the credentials ready..."

echo ""
echo "STEP 3: Enter your credentials:"
echo ""

read -p "ENDPOINT: " ENDPOINT
read -p "ACCESS_KEY_ID: " ACCESS_KEY_ID
read -s -p "SECRET_ACCESS_KEY: " SECRET_ACCESS_KEY
echo ""
read -p "BUCKET (full name): " BUCKET

echo ""
echo "Setting environment variables on Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    if command -v brew &> /dev/null; then
        brew install railway
    elif command -v npm &> /dev/null; then
        npm install -g @railway/cli
    else
        echo "❌ Please install Railway CLI manually:"
        echo "   brew install railway"
        echo "   OR"
        echo "   npm install -g @railway/cli"
        echo ""
        echo "Then run this script again, or set these variables manually in Railway:"
        echo "  S3_ENDPOINT=$ENDPOINT"
        echo "  S3_PUBLIC_ENDPOINT=$ENDPOINT"
        echo "  S3_REGION=us-east-1"
        echo "  S3_ACCESS_KEY_ID=$ACCESS_KEY_ID"
        echo "  S3_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
        echo "  S3_BUCKET=$BUCKET"
        exit 1
    fi
fi

# Login if needed
if ! railway whoami &> /dev/null; then
    echo "Logging into Railway..."
    railway login
fi

# Link project if needed
if [ ! -f .railway/project.json ]; then
    echo "Linking Railway project..."
    echo ""
    echo "📋 Railway CLI will ask you to select:"
    echo "   1. Project: Select 'VoxaNote' (or your project name)"
    echo "   2. Environment: Select 'production'"
    echo "   3. Service: Select 'voxaNote' (your Node.js backend service)"
    echo ""
    read -p "Press Enter to continue with linking..."
    railway link
fi

# Set variables
echo "Setting S3_ENDPOINT..."
railway variables set S3_ENDPOINT="$ENDPOINT"

echo "Setting S3_PUBLIC_ENDPOINT..."
railway variables set S3_PUBLIC_ENDPOINT="$ENDPOINT"

echo "Setting S3_REGION..."
railway variables set S3_REGION="us-east-1"

echo "Setting S3_ACCESS_KEY_ID..."
railway variables set S3_ACCESS_KEY_ID="$ACCESS_KEY_ID"

echo "Setting S3_SECRET_ACCESS_KEY..."
railway variables set S3_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"

echo "Setting S3_BUCKET..."
railway variables set S3_BUCKET="$BUCKET"

echo ""
echo "✅ Done! Railway will automatically redeploy."
echo ""
echo "Testing in 30 seconds..."
sleep 30

echo "Testing endpoint..."
RESPONSE=$(curl -s -X POST https://voxanote-production.up.railway.app/recordings \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","durationSec":10}')

if echo "$RESPONSE" | grep -q "uploadUrl"; then
    echo "✅ SUCCESS! Storage is configured correctly!"
else
    echo "⚠️  Response: $RESPONSE"
    echo "   Railway may still be deploying. Check logs: railway logs"
fi
