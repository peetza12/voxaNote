#!/bin/bash

# Install Railway CLI and run migrations

cd "$(dirname "$0")"

echo "🔧 Installing Railway CLI and Running Migrations"
echo "================================================"
echo ""

# Install Railway CLI
echo "📦 Installing Railway CLI..."
if command -v brew &> /dev/null; then
    brew install railway
elif [ -f "$HOME/.railway/bin/railway" ]; then
    echo "✅ Railway CLI already installed"
    export PATH="$HOME/.railway/bin:$PATH"
else
    # Try official install script
    curl -fsSL https://railway.app/install.sh | sh
    export PATH="$HOME/.railway/bin:$PATH"
fi

# Check if installed
if ! command -v railway &> /dev/null; then
    echo "❌ Failed to install Railway CLI"
    echo ""
    echo "Please install manually:"
    echo "   brew install railway"
    echo "   or visit: https://docs.railway.com/develop/cli"
    exit 1
fi

echo "✅ Railway CLI installed"
echo ""

# Login and link
echo "🔐 Logging into Railway..."
railway login

echo ""
echo "🔗 Linking to project..."
railway link

echo ""
echo "🚀 Connecting to PostgreSQL and running migrations..."
echo ""

# Create a temporary SQL file
cat > /tmp/migrations.sql << 'SQL'
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS recordings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NULL,
  title TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  duration_sec INTEGER NOT NULL,
  storage_url TEXT NOT NULL,
  transcript_text TEXT,
  transcript_json JSONB,
  summary_json JSONB,
  status TEXT NOT NULL DEFAULT 'pending',
  vector_store_id TEXT,
  file_id TEXT
);

CREATE INDEX IF NOT EXISTS idx_recordings_user_id ON recordings(user_id);
CREATE INDEX IF NOT EXISTS idx_recordings_created_at ON recordings(created_at DESC);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recording_id UUID NOT NULL REFERENCES recordings(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_recording_id_created_at
  ON messages(recording_id, created_at);

CREATE TABLE IF NOT EXISTS transcript_chunks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recording_id UUID NOT NULL REFERENCES recordings(id) ON DELETE CASCADE,
  chunk_index INTEGER NOT NULL,
  text TEXT NOT NULL,
  start_sec NUMERIC,
  end_sec NUMERIC,
  embedding vector(1536) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_transcript_chunks_recording_id
  ON transcript_chunks(recording_id);

CREATE INDEX IF NOT EXISTS idx_transcript_chunks_embedding
  ON transcript_chunks
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
SQL

# Get POSTGRES_URL and use psql if available, otherwise use railway connect
POSTGRES_URL=$(railway variables --service postgres 2>/dev/null | grep -E "POSTGRES_URL|DATABASE_URL" | awk '{print $2}' | head -1)

if [ ! -z "$POSTGRES_URL" ] && command -v psql &> /dev/null; then
    echo "✅ Using psql with POSTGRES_URL..."
    psql "$POSTGRES_URL" -f /tmp/migrations.sql
else
    echo "⚠️  Using Railway connect (interactive)..."
    echo "   This will open an interactive psql session."
    echo "   Copy and paste the SQL from /tmp/migrations.sql"
    echo ""
    railway connect postgres
fi

rm -f /tmp/migrations.sql

echo ""
echo "✅ Done! Test your backend:"
echo "   curl https://voxanote-production.up.railway.app/recordings"
