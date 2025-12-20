-- Migration without vector extension (for Railway PostgreSQL)
-- Railway's PostgreSQL may not have pgvector installed

-- Try to create extensions (will fail gracefully if not available)
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'uuid-ossp extension not available, continuing...';
END $$;

-- Skip vector extension for now - Railway may not have it
-- CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS recordings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recording_id UUID NOT NULL REFERENCES recordings(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_recording_id_created_at
  ON messages(recording_id, created_at);

-- Transcript chunks without vector for now
-- We'll add vector support later if pgvector is installed
CREATE TABLE IF NOT EXISTS transcript_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recording_id UUID NOT NULL REFERENCES recordings(id) ON DELETE CASCADE,
  chunk_index INTEGER NOT NULL,
  text TEXT NOT NULL,
  start_sec NUMERIC,
  end_sec NUMERIC,
  embedding TEXT  -- Changed from vector(1536) to TEXT for now
);

CREATE INDEX IF NOT EXISTS idx_transcript_chunks_recording_id
  ON transcript_chunks(recording_id);

-- Skip vector index for now
-- CREATE INDEX IF NOT EXISTS idx_transcript_chunks_embedding
--   ON transcript_chunks
--   USING ivfflat (embedding vector_cosine_ops)
--   WITH (lists = 100);
