import { openai } from '../openaiClient';
import { query } from '../db';

export interface TranscriptChunk {
  id: string;
  recording_id: string;
  chunk_index: number;
  text: string;
  start_sec: number | null;
  end_sec: number | null;
}

const EMBEDDING_MODEL = 'text-embedding-3-small';

export async function indexTranscriptChunks(
  recordingId: string,
  transcript: string,
  segments?: { start: number; end: number; text: string }[]
) {
  // Simple chunking by segments or by fixed length
  const chunks: { text: string; start?: number; end?: number }[] = [];
  if (segments && segments.length > 0) {
    for (const s of segments) {
      if (s.text.trim()) {
        chunks.push({ text: s.text, start: s.start, end: s.end });
      }
    }
  } else {
    const parts = transcript.split(/\n\n+/);
    for (const p of parts) {
      if (p.trim()) {
        chunks.push({ text: p.trim() });
      }
    }
  }

  if (chunks.length === 0) return;

  const embeddingsResponse = await openai.embeddings.create({
    model: EMBEDDING_MODEL,
    input: chunks.map((c) => c.text)
  });

  for (let i = 0; i < chunks.length; i++) {
    const emb = embeddingsResponse.data[i].embedding;
    const start = chunks[i].start ?? null;
    const end = chunks[i].end ?? null;
    // Format embedding array for pgvector: convert to string format [1,2,3]
    const embeddingStr = `[${emb.join(',')}]`;
    await query(
      `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec, embedding)
       VALUES ($1, $2, $3, $4, $5, $6::vector)`,
      [recordingId, i, chunks[i].text, start, end, embeddingStr]
    );
  }
}

export async function searchTranscriptChunks(
  recordingId: string,
  queryText: string,
  limit = 5
) {
  const embedding = await openai.embeddings.create({
    model: EMBEDDING_MODEL,
    input: queryText
  });
  const emb = embedding.data[0].embedding;
  // Format embedding array for pgvector: convert to string format [1,2,3]
  const embeddingStr = `[${emb.join(',')}]`;

  const res = await query<TranscriptChunk & { score: number }>(
    `
      SELECT id, recording_id, chunk_index, text, start_sec, end_sec,
             (embedding <#> $2::vector) AS score
      FROM transcript_chunks
      WHERE recording_id = $1
      ORDER BY score
      LIMIT $3
    `,
    [recordingId, embeddingStr, limit]
  );

  return res.rows;
}



