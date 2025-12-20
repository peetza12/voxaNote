import { Pool } from 'pg';
import { env } from './env';

// Log connection string for debugging (without password)
const logConnectionString = (url: string) => {
  try {
    const urlObj = new URL(url);
    console.log(`[DB] Connecting to: ${urlObj.protocol}//${urlObj.username}@${urlObj.hostname}:${urlObj.port}${urlObj.pathname}`);
  } catch (e) {
    console.log('[DB] Connection string format issue');
  }
};

if (env.postgresUrl) {
  logConnectionString(env.postgresUrl);
} else {
  console.warn('[DB] No database connection string found');
}

export const pool = new Pool({
  connectionString: env.postgresUrl,
  // Add connection timeout and retry logic
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 30000,
});

export async function query<T = any>(text: string, params?: any[]): Promise<{ rows: T[] }> {
  const result = await pool.query(text, params);
  return { rows: result.rows as T[] };
}


