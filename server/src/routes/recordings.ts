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
    const bodySchema = z.object({
      title: z.string().min(1),
      durationSec: z.number().int().positive()
    });
    const parsed = bodySchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.badRequest('Invalid body');
    }
    const { title, durationSec } = parsed.data;
    const { recording, uploadUrl } = await createRecording({ title, durationSec });
    return reply.status(201).send({ recording, uploadUrl });
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
    
    // Check if file exists in S3
    let s3Check = { exists: false, error: null as string | null, bucket: null as string | null, key: null as string | null };
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
    
    return {
      id: recording.id,
      status: recording.status,
      storageUrl: recording.storage_url,
      hasTranscript: !!recording.transcript_text,
      s3Check
    };
  });

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }
    
    // Generate signed playback URL for the audio player
    // Extract bucket from URL for Railway Storage compatibility
    const { parseStorageUrl } = await import('../storage');
    const { bucket, key } = parseStorageUrl(recording.storage_url);
    const playbackUrl = await createSignedPlaybackUrl(key, bucket);
    
    // Return recording with signed playback URL
    return {
      ...recording,
      playbackUrl
    };
  });

  // Use PUT instead of POST to avoid Railway edge 403 issues
  // Railway edge seems to block POST to /:id/process pattern
  app.put('/:id/process', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }

    // Process asynchronously to avoid timeout
    // Return immediately and let processing happen in background
    // Add a small delay to ensure S3 upload has fully completed
    setImmediate(async () => {
      // Wait 2 seconds to ensure S3 upload is fully committed
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      try {
        console.log(`[PROCESS] Starting transcription for ${id}`);
        console.log(`[PROCESS] Storage URL: ${recording.storage_url}`);
        const transcript = await transcribeRecording(id, recording.storage_url);
        console.log(`[PROCESS] Transcription complete for ${id}, generating summary...`);
        const summary = await generateAndStoreSummary(id, transcript.text);
        console.log(`[PROCESS] Summary complete for ${id}, indexing chunks...`);
        try {
          await indexTranscriptChunks(id, transcript.text, transcript.segments);
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
        // Store in transcript_text temporarily so we can retrieve it
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


