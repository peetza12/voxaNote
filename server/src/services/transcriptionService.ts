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

  // OpenAI SDK in Node.js - write to temp file since File API may not be available
  const tempDir = os.tmpdir();
  const tempFilePath = path.join(tempDir, `recording-${recordingId}-${Date.now()}.m4a`);
  
  try {
    // Write buffer to temp file
    fs.writeFileSync(tempFilePath, audioBuffer);
    console.log(`[PROCESS] Wrote ${audioBuffer.length} bytes to temp file: ${tempFilePath}`);
    
    // Create File from temp file using fs.createReadStream
    // OpenAI SDK accepts File, but we'll use the file path approach
    const fileStream = fs.createReadStream(tempFilePath);
    
    // Create transcription with file stream
    console.log(`[PROCESS] Sending ${audioBuffer.length} bytes to OpenAI Whisper API...`);
    let transcription: any;
    try {
      // OpenAI SDK accepts File objects, but in Node.js we can use fs.createReadStream
      // However, the SDK expects a File-like object. Let's try using the temp file path
      // Actually, the OpenAI SDK for Node.js should accept a File, but if not available,
      // we can use the ReadStream directly or create a File-like object
      
      // Check if File is available, otherwise use alternative
      if (typeof File !== 'undefined') {
        const audioFile = new File([audioBuffer], 'recording.m4a', {
          type: 'audio/m4a',
          lastModified: Date.now()
        });
        transcription = await openai.audio.transcriptions.create({
          file: audioFile as any,
          model: 'whisper-1',
          response_format: 'verbose_json'
        });
      } else {
        // File API not available - use fs.ReadStream with proper mime type
        // The OpenAI SDK should accept a stream, but let's use a Blob-like approach
        // Actually, let's just write and read the file as a File object using a polyfill
        const { File: FilePolyfill } = await import('node:buffer');
        const audioFile = new FilePolyfill([audioBuffer], 'recording.m4a', {
          type: 'audio/m4a',
          lastModified: Date.now()
        });
        transcription = await openai.audio.transcriptions.create({
          file: audioFile as any,
          model: 'whisper-1',
          response_format: 'verbose_json'
        });
      }
      
      console.log(`[PROCESS] OpenAI transcription successful, text length: ${transcription.text?.length || 0}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error(`[PROCESS] OpenAI transcription failed: ${errorMessage}`);
      throw new Error(`OpenAI transcription failed: ${errorMessage}`);
    } finally {
      // Clean up temp file
      try {
        fs.unlinkSync(tempFilePath);
        console.log(`[PROCESS] Cleaned up temp file: ${tempFilePath}`);
      } catch (cleanupError) {
        console.warn(`[PROCESS] Failed to clean up temp file: ${tempFilePath}`, cleanupError);
      }
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



