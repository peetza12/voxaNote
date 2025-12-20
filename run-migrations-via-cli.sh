#!/bin/bash

# Run migrations using Railway CLI to connect to PostgreSQL

cd "$(dirname "$0")/server"

echo "🔧 Running Database Migrations via Railway"
echo "==========================================="
echo ""

# Check Railway CLI
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

echo "📋 Getting PostgreSQL connection details..."
echo ""

# Try to get POSTGRES_URL
POSTGRES_URL=$(railway variables --service postgres 2>/dev/null | grep -E "POSTGRES_URL|DATABASE_URL" | awk '{print $2}' | head -1)

if [ -z "$POSTGRES_URL" ]; then
    echo "⚠️  Could not auto-detect POSTGRES_URL"
    echo ""
    echo "Please run this command and copy the POSTGRES_URL:"
    echo "   railway variables --service postgres"
    echo ""
    read -p "Paste the POSTGRES_URL here: " POSTGRES_URL
fi

if [ -z "$POSTGRES_URL" ]; then
    echo "❌ No POSTGRES_URL provided. Exiting."
    exit 1
fi

echo "✅ Using PostgreSQL connection"
echo ""

# Check if we can use psql via Railway connect
echo "🔌 Attempting to connect and run migrations..."
echo ""

# Use Railway's connect command to pipe SQL
railway connect postgres << 'SQL'
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

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migrations completed!"
else
    echo ""
    echo "⚠️  Railway connect method didn't work. Trying alternative..."
    echo ""
    echo "Please install psql and run:"
    echo "   psql \"$POSTGRES_URL\" -f migrations/001_init.sql"
fi
