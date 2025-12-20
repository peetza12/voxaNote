#!/bin/bash

# Automated backend deployment script for Railway
# This script will help you deploy your VoxaNote backend to Railway

set -e

echo "🚀 VoxaNote Backend Deployment to Railway"
echo "=========================================="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
    echo ""
fi

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo "🔐 Please log in to Railway:"
    railway login
    echo ""
fi

cd server

echo "📋 Setting up Railway project..."
echo ""

# Initialize Railway project (if not already initialized)
if [ ! -f "railway.toml" ]; then
    echo "Creating new Railway project..."
    railway init
    echo ""
fi

# Add PostgreSQL database
echo "🗄️  Adding PostgreSQL database..."
railway add postgresql
echo ""

# Link to project
echo "🔗 Linking to Railway project..."
railway link
echo ""

# Get Postgres URL
echo "📥 Getting PostgreSQL connection string..."
POSTGRES_URL=$(railway variables get POSTGRES_URL 2>/dev/null || railway variables --json | grep -o '"POSTGRES_URL":"[^"]*' | cut -d'"' -f4 || echo "")

if [ -z "$POSTGRES_URL" ]; then
    echo "⚠️  Could not automatically get POSTGRES_URL"
    echo "   You'll need to set it manually in Railway dashboard"
else
    echo "✅ Found PostgreSQL URL"
fi

echo ""
echo "🔧 Setting up environment variables..."
echo ""

# Check if .env exists to get values
if [ -f ".env" ]; then
    echo "📝 Found .env file. You'll need to set these in Railway:"
    echo ""
    grep -v "^#" .env | grep -v "^$" | while IFS='=' read -r key value; do
        if [ ! -z "$key" ]; then
            echo "   $key"
        fi
    done
    echo ""
    read -p "Would you like to set environment variables now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Setting environment variables from .env file..."
        
        # Read .env and set variables (skip comments and empty lines)
        while IFS='=' read -r key value || [ -n "$key" ]; do
            # Skip comments and empty lines
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            
            # Remove quotes from value if present
            value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            
            if [ ! -z "$key" ] && [ ! -z "$value" ]; then
                echo "Setting $key..."
                railway variables set "$key=$value" 2>/dev/null || echo "  ⚠️  Could not set $key automatically"
            fi
        done < .env
        
        echo ""
    fi
else
    echo "⚠️  No .env file found. You'll need to set environment variables manually."
    echo ""
    echo "Required variables:"
    echo "  - OPENAI_API_KEY"
    echo "  - S3_ENDPOINT (or use AWS S3)"
    echo "  - S3_ACCESS_KEY_ID"
    echo "  - S3_SECRET_ACCESS_KEY"
    echo "  - S3_BUCKET"
    echo "  - S3_REGION (default: us-east-1)"
    echo ""
    echo "Optional:"
    echo "  - S3_PUBLIC_ENDPOINT"
    echo "  - MAX_RECORDING_SECONDS (default: 3600)"
    echo ""
fi

# Run database migrations
if [ ! -z "$POSTGRES_URL" ]; then
    echo "🗄️  Running database migrations..."
    read -p "Run migrations now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Running migrations..."
        psql "$POSTGRES_URL" -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' || echo "⚠️  Could not create uuid-ossp extension"
        psql "$POSTGRES_URL" -c 'CREATE EXTENSION IF NOT EXISTS vector;' || echo "⚠️  Could not create vector extension"
        psql "$POSTGRES_URL" -f migrations/001_init.sql || echo "⚠️  Could not run migrations"
        echo ""
    fi
fi

# Deploy
echo "🚀 Deploying to Railway..."
echo ""
read -p "Deploy now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    railway up
    echo ""
    echo "⏳ Waiting for deployment to complete..."
    sleep 5
    
    # Get the deployment URL
    echo ""
    echo "🌐 Getting deployment URL..."
    API_URL=$(railway domain 2>/dev/null || railway status --json | grep -o '"domain":"[^"]*' | cut -d'"' -f4 || echo "")
    
    if [ ! -z "$API_URL" ]; then
        # Ensure it starts with https://
        if [[ ! "$API_URL" =~ ^https?:// ]]; then
            API_URL="https://$API_URL"
        fi
        
        echo ""
        echo "✅ Deployment complete!"
        echo ""
        echo "📋 Your production API URL:"
        echo "   $API_URL"
        echo ""
        echo "🧪 Testing connection..."
        if curl -s "$API_URL/health" > /dev/null; then
            echo "   ✅ Server is responding!"
        else
            echo "   ⚠️  Server may still be starting up. Wait a minute and try:"
            echo "   curl $API_URL/health"
        fi
        echo ""
        echo "📱 Next steps:"
        echo "   1. Build iOS: cd mobile_flutter && ./build-ios-release.sh $API_URL"
        echo "   2. Build Android: cd mobile_flutter && ./build-android-release.sh $API_URL"
        echo ""
        echo "💾 Save this URL - you'll need it for building your mobile apps!"
        echo "$API_URL" > ../.production-api-url.txt
        echo "(Saved to .production-api-url.txt)"
    else
        echo ""
        echo "⚠️  Could not automatically get deployment URL"
        echo "   Check Railway dashboard for your app URL"
        echo "   Or run: railway domain"
    fi
else
    echo ""
    echo "⏭️  Skipping deployment. Run 'railway up' when ready."
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📖 To deploy later, run:"
echo "   cd server && railway up"
echo ""
echo "📖 To view logs:"
echo "   railway logs"
echo ""
echo "📖 To open Railway dashboard:"
echo "   railway open"
