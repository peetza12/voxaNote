import { openai } from '../openaiClient';
import { query } from '../db';
import { searchTranscriptChunks } from './retrievalService';

export interface ChatMessage {
  id: string;
  recording_id: string;
  role: 'user' | 'assistant';
  content: string;
  created_at: string;
}

export interface ChatAnswerCitation {
  text: string;
  start_sec: number | null;
  end_sec: number | null;
}

export interface ChatAnswer {
  answer: string;
  citations: ChatAnswerCitation[];
}

export async function getMessages(recordingId: string): Promise<ChatMessage[]> {
  const res = await query<ChatMessage>(
    'SELECT * FROM messages WHERE recording_id = $1 ORDER BY created_at ASC',
    [recordingId]
  );
  return res.rows;
}

export async function addMessage(input: {
  recordingId: string;
  role: 'user' | 'assistant';
  content: string;
}): Promise<ChatMessage> {
  const res = await query<ChatMessage>(
    `INSERT INTO messages (recording_id, role, content)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [input.recordingId, input.role, input.content]
  );
  return res.rows[0];
}

export async function answerQuestion(recordingId: string, question: string): Promise<ChatAnswer> {
  const history = await getMessages(recordingId);
  const topChunks = await searchTranscriptChunks(recordingId, question, 5);

  const contextText = topChunks
    .map(
      (c, i) =>
        `Chunk ${i + 1} [${c.start_sec ?? '?'}s - ${c.end_sec ?? '?'}s]:\n${c.text}`
    )
    .join('\n\n');

  const messagesForModel = [
    {
      role: 'system' as const,
      content:
        'You are an assistant that answers questions about a single transcript. Use ONLY the provided chunks; if the answer is not present, say you do not know. Cite chunks by referencing their timestamps.'
    },
    {
      role: 'user' as const,
      content: `Transcript context:\n${contextText}\n\nQuestion: ${question}`
    }
  ];

  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: messagesForModel
  });

  const answer = completion.choices[0]?.message?.content ?? '';

  await addMessage({ recordingId, role: 'user', content: question });
  await addMessage({ recordingId, role: 'assistant', content: answer });

  const citations = topChunks.map((c) => ({
    text: c.text,
    start_sec: c.start_sec,
    end_sec: c.end_sec
  }));

  return { answer, citations };
}


