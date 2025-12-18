import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { z } from 'zod';
import {
  createRecording,
  listRecordings,
  getRecording,
  deleteRecording
} from '../services/recordingService';
import { transcribeRecording } from '../services/transcriptionService';
import { generateAndStoreSummary } from '../services/summaryService';
import { indexTranscriptChunks } from '../services/retrievalService';
import { answerQuestion, getMessages } from '../services/chatService';

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

  app.get('/:id', async (request) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      throw new Error('Not found');
    }
    return recording;
  });

  app.post('/:id/process', async (request) => {
    const { id } = request.params as { id: string };
    const recording = await getRecording(id);
    if (!recording) {
      throw new Error('Not found');
    }

    const transcript = await transcribeRecording(id, recording.storage_url);
    const summary = await generateAndStoreSummary(id, transcript.text);
    await indexTranscriptChunks(id, transcript.text, transcript.segments);

    return { id, status: 'ready', summary };
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


