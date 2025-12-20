import Fastify from 'fastify';
import cors from '@fastify/cors';
import sensible from '@fastify/sensible';
import { env } from './env';
import { registerRecordingRoutes } from './routes/recordings';

async function buildServer() {
  const app = Fastify({
    logger: true
  });

  await app.register(cors, { origin: true });
  await app.register(sensible);

  app.get('/health', async () => {
    return { status: 'ok' };
  });

  // Test endpoint to verify OpenAI API key
  app.get('/test-openai', async () => {
    const { openai } = await import('./openaiClient');
    const { env } = await import('./env');
    
    if (!env.openaiApiKey) {
      return { 
        success: false, 
        error: 'OPENAI_API_KEY is not set in environment variables' 
      };
    }
    
    if (env.openaiApiKey.length < 20) {
      return { 
        success: false, 
        error: 'OPENAI_API_KEY appears to be too short (likely invalid)' 
      };
    }
    
    try {
      // Make a simple API call to test the key
      const response = await openai.models.list();
      return { 
        success: true, 
        message: 'OpenAI API key is valid and working',
        keyLength: env.openaiApiKey.length,
        keyPrefix: env.openaiApiKey.substring(0, 7) + '...',
        modelsAvailable: response.data.length > 0
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      return { 
        success: false, 
        error: `OpenAI API call failed: ${errorMessage}`,
        keyLength: env.openaiApiKey.length,
        keyPrefix: env.openaiApiKey.substring(0, 7) + '...'
      };
    }
  });

  await app.register(registerRecordingRoutes, { prefix: '/recordings' });

  return app;
}

async function start() {
  const app = await buildServer();
  try {
    await app.listen({ port: env.port, host: '0.0.0.0' });
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

if (require.main === module) {
  void start();
}

export { buildServer };


