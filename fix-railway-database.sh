#!/bin/bash

# Fix Railway database connection using CLI

echo "🔧 Fixing Railway Database Connection"
echo "======================================"
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
    echo ""
fi

echo "🔐 Step 1: Login to Railway"
echo "   (This will open your browser)"
railway login

echo ""
echo "🔗 Step 2: Link to your project"
echo "   (Select your VoxaNote project when prompted)"
railway link

echo ""
echo "📋 Step 3: Check current variables"
railway variables

echo ""
echo "✅ If POSTGRES_URL is missing, you'll need to:"
echo "   1. Go to Railway dashboard"
echo "   2. Find your PostgreSQL service"
echo "   3. Copy the connection URL"
echo "   4. Run: railway variables set POSTGRES_URL='your-url-here'"
echo ""
echo "Or tell me what you see and I'll help you set it up!"
