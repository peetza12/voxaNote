import OpenAI from 'openai';
import { env } from './env';

if (!env.openaiApiKey) {
  // eslint-disable-next-line no-console
  console.warn('OPENAI_API_KEY is not set; AI features will not work');
}

export const openai = new OpenAI({
  apiKey: env.openaiApiKey
});


