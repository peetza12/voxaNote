import { Pool } from 'pg';
import { env } from './env';

export const pool = new Pool({
  connectionString: env.postgresUrl
});

export async function query<T = any>(text: string, params?: any[]): Promise<{ rows: T[] }> {
  const result = await pool.query(text, params);
  return { rows: result.rows as T[] };
}


