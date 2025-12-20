#!/bin/bash

# Simple script to run migrations using Node.js

cd "$(dirname "$0")/server"

echo "🔧 Running Database Migrations"
echo "==============================="
echo ""

# Try to get POSTGRES_URL from Railway CLI if available
if command -v railway &> /dev/null; then
    echo "📋 Getting POSTGRES_URL from Railway..."
    POSTGRES_URL=$(railway variables --service postgres 2>/dev/null | grep -E "POSTGRES_URL|DATABASE_URL" | awk '{print $2}' | head -1)
    
    if [ ! -z "$POSTGRES_URL" ]; then
        echo "✅ Found POSTGRES_URL"
        export POSTGRES_URL
    fi
fi

# If still not set, ask user
if [ -z "$POSTGRES_URL" ]; then
    echo "⚠️  POSTGRES_URL not found automatically"
    echo ""
    echo "Please provide your PostgreSQL connection URL:"
    echo "  1. Go to Railway dashboard"
    echo "  2. Click PostgreSQL service"
    echo "  3. Go to Variables tab"
    echo "  4. Copy POSTGRES_URL or DATABASE_URL"
    echo ""
    read -p "Paste POSTGRES_URL here: " POSTGRES_URL
    export POSTGRES_URL
fi

if [ -z "$POSTGRES_URL" ]; then
    echo "❌ POSTGRES_URL is required. Exiting."
    exit 1
fi

echo ""
echo "🚀 Running migrations..."
echo ""

# Run the Node.js migration script
node run-migrations.js

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All done! Your database is ready."
else
    echo ""
    echo "❌ Migration failed. Check the error above."
    exit 1
fi
