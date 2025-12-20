import { openai } from '../openaiClient';
import { query } from '../db';
import { updateRecordingStatus } from './recordingService';
import { downloadFromS3, getKeyFromStorageUrl } from '../storage';

export interface TranscriptSegment {
  start: number;
  end: number;
  text: string;
}

export interface TranscriptResult {
  text: string;
  segments: TranscriptSegment[];
}

export async function transcribeRecording(
  recordingId: string,
  storageUrl: string
): Promise<TranscriptResult> {
  await updateRecordingStatus(recordingId, 'processing');

  // Extract S3 key from storage URL and download using S3 client with credentials
  const key = getKeyFromStorageUrl(storageUrl);
  console.log(`[PROCESS] Downloading audio from S3 key: ${key}`);
  const audioBuffer = await downloadFromS3(key);

  // OpenAI SDK in Node.js expects a File object
  // Create File from Buffer - Node.js 18+ has File API
  const audioFile = new File([audioBuffer], 'recording.m4a', {
    type: 'audio/m4a',
    lastModified: Date.now()
  });

  // Create transcription with proper file format
  const transcription: any = await openai.audio.transcriptions.create({
    file: audioFile as any, // Type assertion needed for Node.js File compatibility
    model: 'whisper-1',
    response_format: 'verbose_json'
  });

  const text = transcription.text as string;
  const segments: TranscriptSegment[] = (transcription.segments || []).map((s: any) => ({
    start: s.start,
    end: s.end,
    text: s.text
  }));

  await query(
    'UPDATE recordings SET transcript_text = $2, transcript_json = $3, status = $4 WHERE id = $1',
    [recordingId, text, JSON.stringify({ segments }), 'uploaded']
  );

  return { text, segments };
}



