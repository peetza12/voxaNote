import { query } from '../db';
import { createSignedUploadUrl, getPublicUrlFromKey } from '../storage';

export type RecordingStatus = 'pending' | 'uploaded' | 'processing' | 'ready' | 'error';

export interface Recording {
  id: string;
  user_id: string | null;
  title: string;
  created_at: string;
  duration_sec: number;
  storage_url: string;
  transcript_text: string | null;
  transcript_json: any | null;
  summary_json: any | null;
  status: RecordingStatus;
}

export async function createRecording(input: {
  userId?: string | null;
  title: string;
  durationSec: number;
}): Promise<{ recording: Recording; uploadUrl: string }> {
  const { userId = null, title, durationSec } = input;
  const { key, url } = await createSignedUploadUrl(userId);
  const storageUrl = getPublicUrlFromKey(key);

  const res = await query<Recording>(
    `INSERT INTO recordings (user_id, title, duration_sec, storage_url, status)
     VALUES ($1, $2, $3, $4, 'pending')
     RETURNING *`,
    [userId, title, durationSec, storageUrl]
  );

  return { recording: res.rows[0], uploadUrl: url };
}

export async function listRecordings(userId?: string | null): Promise<Recording[]> {
  if (userId) {
    const res = await query<Recording>(
      'SELECT * FROM recordings WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    return res.rows;
  }
  const res = await query<Recording>('SELECT * FROM recordings ORDER BY created_at DESC');
  return res.rows;
}

export async function getRecording(id: string, userId?: string | null): Promise<Recording | null> {
  const res = await query<Recording>(
    'SELECT * FROM recordings WHERE id = $1 AND ($2::uuid IS NULL OR user_id = $2)',
    [id, userId || null]
  );
  return res.rows[0] || null;
}

export async function updateRecordingStatus(id: string, status: RecordingStatus) {
  await query('UPDATE recordings SET status = $2 WHERE id = $1', [id, status]);
}

export async function deleteRecording(id: string, userId?: string | null) {
  await query('DELETE FROM recordings WHERE id = $1 AND ($2::uuid IS NULL OR user_id = $2)', [
    id,
    userId || null
  ]);
}


