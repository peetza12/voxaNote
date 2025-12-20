#!/bin/bash

# Run database migrations using Railway CLI

echo "🔧 Running Database Migrations"
echo "==============================="
echo ""

cd "$(dirname "$0")/server"

# Check if Railway CLI is available
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found"
    echo "   Install it: npm install -g @railway/cli"
    exit 1
fi

# Get POSTGRES_URL from Railway
echo "📋 Getting PostgreSQL connection URL..."
POSTGRES_URL=$(railway variables --service postgres 2>/dev/null | grep -i "POSTGRES_URL\|DATABASE_URL" | awk '{print $2}' | head -1)

if [ -z "$POSTGRES_URL" ]; then
    echo "❌ Could not find POSTGRES_URL"
    echo ""
    echo "Please run manually:"
    echo "  1. Get POSTGRES_URL: railway variables --service postgres"
    echo "  2. Run: psql \"YOUR_URL\" -f migrations/001_init.sql"
    exit 1
fi

echo "✅ Found POSTGRES_URL"
echo ""

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo "❌ psql not found"
    echo ""
    echo "Please use Railway's database console instead:"
    echo "  1. Click PostgreSQL service in Railway"
    echo "  2. Go to 'Data' or 'Query' tab"
    echo "  3. Run the SQL from migrations/001_init.sql"
    exit 1
fi

# Run migrations
echo "🚀 Running migrations..."
psql "$POSTGRES_URL" -f migrations/001_init.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migrations completed successfully!"
    echo ""
    echo "🧪 Test your backend:"
    echo "   curl https://voxanote-production.up.railway.app/recordings"
else
    echo ""
    echo "❌ Migration failed. Check the error above."
    exit 1
fi
