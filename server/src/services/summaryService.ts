import { openai } from '../openaiClient';
import { query } from '../db';

export interface SummaryJson {
  title: string;
  bullet_summary: string[];
  action_items: string[];
  topics: string[];
  key_entities?: string[];
  key_dates?: string[];
}

export async function generateAndStoreSummary(recordingId: string, transcript: string): Promise<SummaryJson> {
  const systemPrompt =
    'You are an assistant that summarizes meeting or personal voice notes into structured JSON.';
  const userPrompt = `
Summarize the following transcript into this JSON structure:
{
  "title": string,
  "bullet_summary": string[5],
  "action_items": string[],
  "topics": string[],
  "key_entities": string[] (optional),
  "key_dates": string[] (optional)
}

Transcript:
${transcript}
`;

  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ],
    response_format: { type: 'json_object' }
  });

  const content = completion.choices[0]?.message?.content;
  const json = typeof content === 'string' ? JSON.parse(content) : JSON.parse(content ?? '{}');

  const summary: SummaryJson = {
    title: json.title ?? 'Untitled',
    bullet_summary: json.bullet_summary ?? [],
    action_items: json.action_items ?? [],
    topics: json.topics ?? [],
    key_entities: json.key_entities ?? [],
    key_dates: json.key_dates ?? []
  };

  await query('UPDATE recordings SET summary_json = $2 WHERE id = $1', [
    recordingId,
    JSON.stringify(summary)
  ]);

  return summary;
}


