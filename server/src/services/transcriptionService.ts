import { openai } from '../openaiClient';
import { query } from '../db';
import { updateRecordingStatus } from './recordingService';
import { downloadFromS3, getKeyFromStorageUrl } from '../storage';
import { toFile } from 'openai/uploads';

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

  // Extract S3 bucket and key from storage URL
  // Railway Storage requires using the bucket name from the URL, not the env var
  const { parseStorageUrl } = await import('../storage');
  const { bucket, key } = parseStorageUrl(storageUrl);
  console.log(`[PROCESS] Downloading audio from S3 bucket: ${bucket}, key: ${key}`);
  console.log(`[PROCESS] Storage URL: ${storageUrl}`);
  
  let audioBuffer: Buffer;
  try {
    const { downloadFromS3 } = await import('../storage');
    audioBuffer = await downloadFromS3(key, bucket);
    console.log(`[PROCESS] Downloaded ${audioBuffer.length} bytes from S3`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error(`[PROCESS] S3 download failed: ${errorMessage}`);
    throw new Error(`Failed to download audio from S3: ${errorMessage}`);
  }

  // Convert Buffer to File-like object using OpenAI SDK's toFile utility
  console.log(`[PROCESS] Converting ${audioBuffer.length} bytes to file object...`);
  const audioFile = await toFile(audioBuffer, 'recording.m4a');
  
  // Create transcription with proper file format and retry logic
  console.log(`[PROCESS] Sending ${audioFile.size} bytes to OpenAI Whisper API...`);
  let transcription: any;
  const maxRetries = 3;
  let lastError: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`[PROCESS] OpenAI API call attempt ${attempt}/${maxRetries}...`);
      transcription = await openai.audio.transcriptions.create({
        file: audioFile,
        model: 'whisper-1',
        response_format: 'verbose_json'
      });
      console.log(`[PROCESS] OpenAI transcription successful, text length: ${transcription.text?.length || 0}`);
      break; // Success, exit retry loop
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      const errorMessage = lastError.message;
      console.error(`[PROCESS] OpenAI transcription attempt ${attempt} failed: ${errorMessage}`);
      
      // If it's a connection error and we have retries left, wait and retry
      if (attempt < maxRetries && (
        errorMessage.includes('Connection') || 
        errorMessage.includes('ECONNREFUSED') ||
        errorMessage.includes('ETIMEDOUT') ||
        errorMessage.includes('timeout')
      )) {
        const waitTime = attempt * 2000; // Exponential backoff: 2s, 4s, 6s
        console.log(`[PROCESS] Retrying in ${waitTime}ms...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
        continue;
      }
      
      // If it's not a retryable error or we're out of retries, throw
      throw new Error(`OpenAI transcription failed: ${errorMessage}`);
    }
  }
  
  if (!transcription && lastError) {
    throw new Error(`OpenAI transcription failed after ${maxRetries} attempts: ${lastError.message}`);
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



