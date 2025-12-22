import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { z } from 'zod';
import {
  createRecording,
  listRecordings,
  getRecording,
  deleteRecording
} from '../services/recordingService';
import { createSignedPlaybackUrl, getKeyFromStorageUrl } from '../storage';
import { transcribeRecording } from '../services/transcriptionService';
import { generateAndStoreSummary } from '../services/summaryService';
import { indexTranscriptChunks } from '../services/retrievalService';
import { answerQuestion, getMessages } from '../services/chatService';
import { query } from '../db';

export async function registerRecordingRoutes(app: FastifyInstance, _opts: FastifyPluginOptions) {
  app.post('/', async (request, reply) => {
    // Support both old format (for backward compatibility) and new format with transcript
    const bodySchema = z.object({
      title: z.string().min(1),
      durationSec: z.number().int().positive(),
      transcriptText: z.string().optional() // New: transcript text from speech-to-text
    });
    const parsed = bodySchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.badRequest('Invalid body');
    }
    const { title, durationSec, transcriptText } = parsed.data;
    
    console.log(`[CREATE] Received request: title="${title}", durationSec=${durationSec}, transcriptText=${transcriptText ? `"${transcriptText.substring(0, 50)}..." (${transcriptText.length} chars)` : 'null'}`);
    
    // If transcript text is provided, use new flow
    if (transcriptText && transcriptText.trim().length > 0) {
      console.log(`[CREATE] Using transcript-only flow (no storage)`);
      const recording = await createRecording({
        title,
        durationSec,
        transcriptText: transcriptText.trim()
      });
      console.log(`[CREATE] Created recording: id=${recording.recording.id}, hasTranscript=${!!recording.recording.transcript_text}, storageUrl=${recording.recording.storage_url}`);
      return reply.status(201).send({ recording: recording.recording });
    } else {
      console.log(`[CREATE] Using legacy flow (with storage URL)`);
      // Legacy flow: create recording with upload URL (for backward compatibility)
      const { recording, uploadUrl } = await createRecording({ title, durationSec });
      return reply.status(201).send({ recording, uploadUrl });
    }
  });

  app.get('/', async () => {
    const recordings = await listRecordings();
    return recordings;
  });

  // Diagnostic endpoint - must be before /:id route
  app.get('/:id/status', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }
    
    // Check if file exists in S3 (only for legacy recordings with storage_url)
    let s3Check = { exists: false, error: null as string | null, bucket: null as string | null, key: null as string | null };
    if (recording.storage_url) {
      try {
        const { parseStorageUrl, downloadFromS3 } = await import('../storage');
        const { bucket, key } = parseStorageUrl(recording.storage_url);
        s3Check.bucket = bucket;
        s3Check.key = key;
        await downloadFromS3(key, bucket);
        s3Check.exists = true;
      } catch (error) {
        s3Check.error = error instanceof Error ? error.message : String(error);
      }
    }
    
    return {
      id: recording.id,
      status: recording.status,
      storageUrl: recording.storage_url || null,
      hasTranscript: !!recording.transcript_text,
      s3Check
    };
  });

  // Synchronous processing endpoint - processes immediately and returns when done (Otter-like)
  // MUST be before /:id route to avoid route matching conflicts
  // Use PUT to avoid Railway edge blocking POST to /:id/* pattern
  app.put('/:id/process-sync', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }

    try {
      let transcriptText: string;
      let transcriptSegments: { start: number; end: number; text: string }[] | undefined;

      // If transcript already exists (from speech-to-text), use it directly
      if (recording.transcript_text) {
        console.log(`[PROCESS SYNC] Using existing transcript for ${id}`);
        console.log(`[PROCESS SYNC] Transcript length: ${recording.transcript_text.length} characters`);
        transcriptText = recording.transcript_text;
        if (!transcriptText || transcriptText.trim().length === 0) {
          return reply.status(400).send({ error: 'Transcript text is empty' });
        }
        // Try to parse segments from transcript_json if available
        if (recording.transcript_json && recording.transcript_json.segments) {
          transcriptSegments = recording.transcript_json.segments;
        }
      } else if (recording.storage_url) {
        // Legacy flow: transcribe from audio file (for backward compatibility)
        console.log(`[PROCESS SYNC] Starting transcription for ${id}`);
        console.log(`[PROCESS SYNC] Storage URL: ${recording.storage_url}`);
        await new Promise(resolve => setTimeout(resolve, 2000));
        const transcript = await transcribeRecording(id, recording.storage_url);
        transcriptText = transcript.text;
        transcriptSegments = transcript.segments;
      } else {
        return reply.status(400).send({ error: 'No transcript text or storage URL available' });
      }

      console.log(`[PROCESS SYNC] Transcript ready for ${id}, generating summary...`);
      const summary = await generateAndStoreSummary(id, transcriptText);
      console.log(`[PROCESS SYNC] Summary complete for ${id}, indexing chunks...`);
      
      try {
        await indexTranscriptChunks(id, transcriptText, transcriptSegments);
        console.log(`[PROCESS SYNC] Chunk indexing complete for ${id}`);
      } catch (chunkError) {
        // Chunk indexing errors are non-fatal - log but continue
        const chunkErrorMessage = chunkError instanceof Error ? chunkError.message : String(chunkError);
        console.warn(`[PROCESS SYNC] Chunk indexing had issues (chat may be limited): ${chunkErrorMessage}`);
      }
      
      // Update status to 'ready' after all processing is complete
      await query('UPDATE recordings SET status = $1 WHERE id = $2', ['ready', id]);
      console.log(`[PROCESS SYNC] Processing complete for ${id}, status set to 'ready'`);
      
      return reply.send({ id, status: 'ready', summary });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      const errorStack = error instanceof Error ? error.stack : undefined;
      console.error(`[PROCESS SYNC] Processing failed for ${id}:`, errorMessage);
      if (errorStack) {
        console.error(`[PROCESS SYNC] Error stack:`, errorStack);
      }
      // Store error message in database
      await query(
        'UPDATE recordings SET status = $1, transcript_text = $2 WHERE id = $3',
        ['error', `ERROR: ${errorMessage}`, id]
      );
      return reply.status(500).send({ error: errorMessage });
    }
  });

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }
    
    // Generate signed playback URL only if storage_url exists (legacy recordings)
    let playbackUrl: string | null = null;
    if (recording.storage_url) {
      try {
        const { parseStorageUrl } = await import('../storage');
        const { bucket, key } = parseStorageUrl(recording.storage_url);
        playbackUrl = await createSignedPlaybackUrl(key, bucket);
      } catch (error) {
        // If storage URL is invalid or doesn't exist, playbackUrl remains null
        console.warn(`[GET] Could not generate playback URL for ${id}:`, error);
      }
    }
    
    // Return recording with optional playback URL
    return {
      ...recording,
      playbackUrl
    };
  });

  // Use PUT instead of POST to avoid Railway edge 403 issues
  // Railway edge seems to block POST to /:id/process pattern
  // This is the async version (for backward compatibility)
  app.put('/:id/process', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }

    // Process asynchronously to avoid timeout
    // Return immediately and let processing happen in background
    setImmediate(async () => {
      try {
        // Re-fetch recording to ensure we have latest data (including transcript_text)
        const freshRecording = await getRecording(id);
        if (!freshRecording) {
          throw new Error('Recording not found');
        }
        
        console.log(`[PROCESS] Processing recording ${id}`);
        console.log(`[PROCESS] Has transcript_text: ${!!freshRecording.transcript_text}`);
        console.log(`[PROCESS] Has storage_url: ${!!freshRecording.storage_url}`);
        console.log(`[PROCESS] Transcript length: ${freshRecording.transcript_text?.length || 0}`);
        
        let transcriptText: string;
        let transcriptSegments: { start: number; end: number; text: string }[] | undefined;

        // If transcript already exists (from speech-to-text), use it directly
        if (freshRecording.transcript_text && freshRecording.transcript_text.trim().length > 0) {
          console.log(`[PROCESS] Using existing transcript for ${id}`);
          console.log(`[PROCESS] Transcript length: ${freshRecording.transcript_text.length} characters`);
          transcriptText = freshRecording.transcript_text;
          // Try to parse segments from transcript_json if available
          if (freshRecording.transcript_json && freshRecording.transcript_json.segments) {
            transcriptSegments = freshRecording.transcript_json.segments;
          }
        } else if (freshRecording.storage_url && (!freshRecording.transcript_text || freshRecording.transcript_text.trim().length === 0)) {
          // Legacy flow: transcribe from audio file (for backward compatibility)
          // Only do this if we DON'T have transcript_text or it's empty
          console.log(`[PROCESS] Starting transcription from audio for ${id}`);
          console.log(`[PROCESS] Storage URL: ${freshRecording.storage_url}`);
          // Wait a bit to ensure S3 upload is committed (if applicable)
          await new Promise(resolve => setTimeout(resolve, 2000));
          const transcript = await transcribeRecording(id, freshRecording.storage_url);
          transcriptText = transcript.text;
          transcriptSegments = transcript.segments;
        } else {
          // If we have neither transcript_text nor storage_url, that's an error
          const errorMsg = freshRecording.transcript_text 
            ? `Transcript text exists but is empty: "${freshRecording.transcript_text}"`
            : 'No transcript text or storage URL available';
          throw new Error(errorMsg);
        }

        console.log(`[PROCESS] Transcript ready for ${id}, generating summary...`);
        const summary = await generateAndStoreSummary(id, transcriptText);
        console.log(`[PROCESS] Summary complete for ${id}, indexing chunks...`);
        
        try {
          await indexTranscriptChunks(id, transcriptText, transcriptSegments);
          console.log(`[PROCESS] Chunk indexing complete for ${id}`);
        } catch (chunkError) {
          // Chunk indexing errors are non-fatal - log but continue
          const chunkErrorMessage = chunkError instanceof Error ? chunkError.message : String(chunkError);
          console.warn(`[PROCESS] Chunk indexing had issues (chat may be limited): ${chunkErrorMessage}`);
          // Don't throw - processing should continue even if chunking fails
        }
        
        // Update status to 'ready' after all processing is complete
        await query('UPDATE recordings SET status = $1 WHERE id = $2', ['ready', id]);
        console.log(`[PROCESS] Processing complete for ${id}, status set to 'ready'`);
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        const errorStack = error instanceof Error ? error.stack : undefined;
        console.error(`[PROCESS] Processing failed for ${id}:`, errorMessage);
        if (errorStack) {
          console.error(`[PROCESS] Error stack:`, errorStack);
        }
        // Store error message in database for debugging
        await query(
          'UPDATE recordings SET status = $1, transcript_text = $2 WHERE id = $3',
          ['error', `ERROR: ${errorMessage}`, id]
        );
      }
    });

    return reply.status(202).send({ id, status: 'processing' });
  });

  app.get('/:id/messages', async (request) => {
    const { id } = request.params as { id: string };
    const messages = await getMessages(id);
    return messages;
  });

  app.post('/:id/chat', async (request, reply) => {
    const { id } = request.params as { id: string };
    const bodySchema = z.object({
      question: z.string().min(1)
    });
    const parsed = bodySchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.badRequest('Invalid body');
    }
    const { question } = parsed.data;
    const answer = await answerQuestion(id, question);
    return { id, ...answer };
  });

  app.delete('/:id', async (request, reply) => {
    const { id } = request.params as { id: string };
    await deleteRecording(id);
    return reply.status(204).send();
  });
}


