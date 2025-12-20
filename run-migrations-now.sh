#!/bin/bash

# Run migrations with DATABASE_URL

cd "$(dirname "$0")/server"

echo "🔧 Running Database Migrations"
echo "==============================="
echo ""

if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL is not set"
    echo ""
    echo "Please set it first:"
    echo "   export DATABASE_URL='your-database-url-here'"
    echo "   ./run-migrations-now.sh"
    echo ""
    echo "Or run with the URL:"
    echo "   DATABASE_URL='your-url' ./run-migrations-now.sh"
    exit 1
fi

echo "✅ Using DATABASE_URL"
echo ""
echo "🚀 Running migrations..."
echo ""

# Use POSTGRES_URL for the script (it checks for that)
export POSTGRES_URL="$DATABASE_URL"

# Run the migration script
node run-migrations.js

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migrations completed!"
    echo ""
    echo "🧪 Test your backend:"
    echo "   curl https://voxanote-production.up.railway.app/recordings"
else
    echo ""
    echo "❌ Migration failed. Check the error above."
    exit 1
fi
