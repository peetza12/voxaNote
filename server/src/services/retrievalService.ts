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

  // Store chunks without embeddings (vector extension not available)
  // We'll compute embeddings on-the-fly during search
  for (let i = 0; i < chunks.length; i++) {
    const start = chunks[i].start ?? null;
    const end = chunks[i].end ?? null;
    
    // Try to insert with embedding column, fall back to without if vector type doesn't exist
    try {
      // First, try to insert without embedding (in case table doesn't have embedding column)
      await query(
        `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT DO NOTHING`,
        [recordingId, i, chunks[i].text, start, end]
      );
    } catch (error) {
      // If that fails, try with embedding as NULL
      const errorMessage = error instanceof Error ? error.message : String(error);
      if (errorMessage.includes('embedding') || errorMessage.includes('vector')) {
        // Table might have embedding column but vector type doesn't exist
        // Try inserting with NULL embedding
        try {
          await query(
            `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec, embedding)
             VALUES ($1, $2, $3, $4, $5, NULL)
             ON CONFLICT DO NOTHING`,
            [recordingId, i, chunks[i].text, start, end]
          );
        } catch (e2) {
          // Last resort: insert without embedding column
          await query(
            `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT DO NOTHING`,
            [recordingId, i, chunks[i].text, start, end]
          );
        }
      } else {
        throw error;
      }
    }
  }
}

export async function searchTranscriptChunks(
  recordingId: string,
  queryText: string,
  limit = 5
) {
  // Get all chunks for this recording
  const allChunksRes = await query<TranscriptChunk>(
    `SELECT id, recording_id, chunk_index, text, start_sec, end_sec
     FROM transcript_chunks
     WHERE recording_id = $1
     ORDER BY chunk_index`,
    [recordingId]
  );

  if (allChunksRes.rows.length === 0) {
    return [];
  }

  // Use OpenAI embeddings to find similar chunks (in-memory comparison)
  try {
    // Get embedding for the query
    const queryEmbedding = await openai.embeddings.create({
      model: EMBEDDING_MODEL,
      input: queryText
    });
    const queryEmb = queryEmbedding.data[0].embedding;

    // Get embeddings for all chunks (batch request)
    const chunkTexts = allChunksRes.rows.map(c => c.text);
    const chunkEmbeddings = await openai.embeddings.create({
      model: EMBEDDING_MODEL,
      input: chunkTexts
    });

    // Calculate cosine similarity for each chunk
    const chunksWithScores = allChunksRes.rows.map((chunk, index) => {
      const chunkEmb = chunkEmbeddings.data[index].embedding;
      
      // Cosine similarity: dot product / (magnitude1 * magnitude2)
      let dotProduct = 0;
      let mag1 = 0;
      let mag2 = 0;
      for (let i = 0; i < queryEmb.length; i++) {
        dotProduct += queryEmb[i] * chunkEmb[i];
        mag1 += queryEmb[i] * queryEmb[i];
        mag2 += chunkEmb[i] * chunkEmb[i];
      }
      const similarity = dotProduct / (Math.sqrt(mag1) * Math.sqrt(mag2));
      
      return {
        ...chunk,
        score: 1 - similarity // Convert similarity to distance (lower is better)
      };
    });

    // Sort by score (lower is better) and return top results
    chunksWithScores.sort((a, b) => a.score - b.score);
    return chunksWithScores.slice(0, limit);
  } catch (error) {
    // Fallback to simple text search if embeddings fail
    console.warn('[RETRIEVAL] Embedding search failed, using text search:', error);
    
    const queryLower = queryText.toLowerCase();
    const queryWords = queryLower.split(/\s+/).filter(w => w.length > 2);
    
    const chunksWithScores = allChunksRes.rows.map(chunk => {
      const chunkLower = chunk.text.toLowerCase();
      let score = 0;
      
      // Simple keyword matching: count how many query words appear in chunk
      for (const word of queryWords) {
        if (chunkLower.includes(word)) {
          score += 1;
        }
      }
      
      // Normalize by query word count (higher is better)
      return {
        ...chunk,
        score: queryWords.length > 0 ? (queryWords.length - score) / queryWords.length : 1
      };
    });

    chunksWithScores.sort((a, b) => a.score - b.score);
    return chunksWithScores.slice(0, limit);
  }
}



