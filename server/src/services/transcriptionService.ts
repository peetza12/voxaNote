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
  console.log(`[PROCESS] Storage URL: ${storageUrl}`);
  
  let audioBuffer: Buffer;
  try {
    audioBuffer = await downloadFromS3(key);
    console.log(`[PROCESS] Downloaded ${audioBuffer.length} bytes from S3`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error(`[PROCESS] S3 download failed: ${errorMessage}`);
    throw new Error(`Failed to download audio from S3: ${errorMessage}`);
  }

  // OpenAI SDK in Node.js expects a File object
  // Create File from Buffer - Node.js 18+ has File API
  // Buffer extends Uint8Array which is compatible with BlobPart
  const audioFile = new File([audioBuffer as Uint8Array], 'recording.m4a', {
    type: 'audio/m4a',
    lastModified: Date.now()
  });

  // Create transcription with proper file format
  console.log(`[PROCESS] Sending ${audioFile.size} bytes to OpenAI Whisper API...`);
  let transcription: any;
  try {
    transcription = await openai.audio.transcriptions.create({
      file: audioFile as any, // Type assertion needed for Node.js File compatibility
      model: 'whisper-1',
      response_format: 'verbose_json'
    });
    console.log(`[PROCESS] OpenAI transcription successful, text length: ${transcription.text?.length || 0}`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error(`[PROCESS] OpenAI transcription failed: ${errorMessage}`);
    throw new Error(`OpenAI transcription failed: ${errorMessage}`);
  }

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



