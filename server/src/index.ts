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


