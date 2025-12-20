import OpenAI from 'openai';
import { env } from './env';

if (!env.openaiApiKey) {
  // eslint-disable-next-line no-console
  console.warn('OPENAI_API_KEY is not set; AI features will not work');
}

// Clean the API key: remove "Bearer " prefix if present, trim whitespace/newlines
function cleanApiKey(key: string): string {
  return key
    .trim() // Remove leading/trailing whitespace and newlines
    .replace(/^Bearer\s+/i, ''); // Remove "Bearer " prefix if present
}

const cleanedApiKey = env.openaiApiKey ? cleanApiKey(env.openaiApiKey) : '';

export const openai = new OpenAI({
  apiKey: cleanedApiKey,
  maxRetries: 3,
  timeout: 60000 // 60 second timeout
});


