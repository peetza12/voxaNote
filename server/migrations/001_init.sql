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

-- Chunks of transcript used for retrieval (pgvector)
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


