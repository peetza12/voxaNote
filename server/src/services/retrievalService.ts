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
  // Delete existing chunks for this recording first to avoid duplicates
  try {
    await query('DELETE FROM transcript_chunks WHERE recording_id = $1', [recordingId]);
  } catch (error) {
    // Table might not exist yet, that's okay
    console.warn('[RETRIEVAL] Could not delete existing chunks (table might not exist):', error);
  }
  
  let insertedCount = 0;
  for (let i = 0; i < chunks.length; i++) {
    const start = chunks[i].start ?? null;
    const end = chunks[i].end ?? null;
    
    // Try different insert strategies based on schema
    let inserted = false;
    
    // Strategy 1: Try without embedding column (simplest)
    try {
      await query(
        `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec)
         VALUES ($1, $2, $3, $4, $5)`,
        [recordingId, i, chunks[i].text, start, end]
      );
      inserted = true;
      insertedCount++;
    } catch (error1) {
      const errorMsg1 = error1 instanceof Error ? error1.message : String(error1);
      
      // Strategy 2: Try with NULL embedding (if column exists but allows NULL)
      if (errorMsg1.includes('embedding') || errorMsg1.includes('column')) {
        try {
          await query(
            `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec, embedding)
             VALUES ($1, $2, $3, $4, $5, NULL)`,
            [recordingId, i, chunks[i].text, start, end]
          );
          inserted = true;
          insertedCount++;
        } catch (error2) {
          const errorMsg2 = error2 instanceof Error ? error2.message : String(error2);
          
          // Strategy 3: Try with empty string for embedding (if TEXT column)
          if (errorMsg2.includes('NULL') || errorMsg2.includes('constraint')) {
            try {
              await query(
                `INSERT INTO transcript_chunks (recording_id, chunk_index, text, start_sec, end_sec, embedding)
                 VALUES ($1, $2, $3, $4, $5, '')`,
                [recordingId, i, chunks[i].text, start, end]
              );
              inserted = true;
              insertedCount++;
            } catch (error3) {
              console.error(`[RETRIEVAL] Failed to insert chunk ${i} after all strategies:`, error3);
            }
          } else {
            console.error(`[RETRIEVAL] Failed to insert chunk ${i}:`, error2);
          }
        }
      } else {
        // Different error, might be constraint violation or other issue
        console.warn(`[RETRIEVAL] Failed to insert chunk ${i}:`, error1);
      }
    }
  }
  
  console.log(`[RETRIEVAL] Indexed ${insertedCount}/${chunks.length} chunks for recording ${recordingId}`);
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



