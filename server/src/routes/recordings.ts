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

  app.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      return reply.status(404).send({ error: 'Recording not found' });
    }
    
    // Generate signed playback URL for the audio player
    const key = getKeyFromStorageUrl(recording.storage_url);
    const playbackUrl = await createSignedPlaybackUrl(key);
    
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
    setImmediate(async () => {
      try {
        console.log(`[PROCESS] Starting transcription for ${id}`);
        const transcript = await transcribeRecording(id, recording.storage_url);
        console.log(`[PROCESS] Transcription complete for ${id}, generating summary...`);
        const summary = await generateAndStoreSummary(id, transcript.text);
        console.log(`[PROCESS] Summary complete for ${id}, indexing chunks...`);
        await indexTranscriptChunks(id, transcript.text, transcript.segments);
        console.log(`[PROCESS] Processing complete for ${id}`);
      } catch (error) {
        console.error(`[PROCESS] Processing failed for ${id}:`, error);
        // Update status to error
        await query('UPDATE recordings SET status = $1 WHERE id = $2', ['error', id]);
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


