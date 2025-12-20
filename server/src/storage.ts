import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { env } from './env';
import crypto from 'crypto';

// S3 client for backend operations (uses internal endpoint)
const s3 = new S3Client({
  region: env.s3Region,
  endpoint: env.s3Endpoint || undefined,
  forcePathStyle: !!env.s3Endpoint,
  credentials: {
    accessKeyId: env.s3AccessKeyId,
    secretAccessKey: env.s3SecretAccessKey
  }
});

// S3 client for generating signed URLs that mobile devices can use
// Uses public endpoint so signature is valid for network IP
function getPublicS3Client(): S3Client {
  const publicEndpoint = env.s3PublicEndpoint || env.s3Endpoint;
  return new S3Client({
    region: env.s3Region,
    endpoint: publicEndpoint || undefined,
    forcePathStyle: !!publicEndpoint,
    credentials: {
      accessKeyId: env.s3AccessKeyId,
      secretAccessKey: env.s3SecretAccessKey
    }
  });
}

export async function createSignedUploadUrl(userId: string | null): Promise<{ key: string; url: string }> {
  // Validate S3 configuration
  if (!env.s3Bucket) {
    throw new Error('S3_BUCKET environment variable is not set. Please configure S3 storage in Railway.');
  }
  if (!env.s3AccessKeyId || !env.s3SecretAccessKey) {
    throw new Error('S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY must be set. Please configure S3 credentials in Railway.');
  }

  const key = `recordings/${userId || 'anon'}/${crypto.randomUUID()}.m4a`;
  const command = new PutObjectCommand({
    Bucket: env.s3Bucket,
    Key: key,
    ContentType: 'audio/m4a',
    // Don't include checksum - Railway S3 doesn't require it and it causes issues with mobile uploads
    // ChecksumAlgorithm: undefined
  });

  // Use public S3 client so signed URL uses network IP from the start
  // This ensures the signature is valid for the URL mobile devices will use
  const publicS3 = getPublicS3Client();
  // Don't include checksum in signed URL - simpler for mobile clients
  const url = await getSignedUrl(publicS3, command, { 
    expiresIn: 60 * 15,
    // Remove checksum parameters from signed URL
    signableHeaders: new Set(['host'])
  });
  
  return { key, url };
}

export function getPublicUrlFromKey(key: string): string {
  // Use public endpoint for playback URLs so mobile devices can access them
  const endpoint = (env.s3PublicEndpoint || env.s3Endpoint).replace(/\/$/, '');
  if (endpoint) {
    return `${endpoint}/${env.s3Bucket}/${key}`;
  }
  // Only generate AWS S3 URL if bucket is set
  if (env.s3Bucket) {
    return `https://${env.s3Bucket}.s3.${env.s3Region}.amazonaws.com/${key}`;
  }
  // Fallback - should not happen if validation is working
  throw new Error('S3_BUCKET is not configured. Cannot generate public URL.');
}

/**
 * Extract S3 bucket and key from a storage URL
 * Handles formats like:
 * - https://storage.railway.app/bucket/key
 * - https://bucket.s3.region.amazonaws.com/key
 */
export function parseStorageUrl(storageUrl: string): { bucket: string; key: string } {
  try {
    const url = new URL(storageUrl);
    // Railway format: https://storage.railway.app/bucket/key
    if (url.pathname.startsWith('/')) {
      const parts = url.pathname.split('/').filter(p => p);
      if (parts.length < 2) {
        throw new Error(`Invalid storage URL format: ${storageUrl}`);
      }
      // First part is bucket, rest is key
      return {
        bucket: parts[0],
        key: parts.slice(1).join('/')
      };
    }
    // AWS format: https://bucket.s3.region.amazonaws.com/key
    return {
      bucket: env.s3Bucket, // Use env var for AWS format
      key: url.pathname.substring(1) // Remove leading /
    };
  } catch {
    // If URL parsing fails, try to extract from common patterns
    const match = storageUrl.match(/https?:\/\/[^/]+\/([^/]+)\/(.+)$/);
    if (match) {
      return { bucket: match[1], key: match[2] };
    }
    throw new Error(`Could not parse storage URL: ${storageUrl}`);
  }
}

/**
 * Extract S3 key from a storage URL (backward compatibility)
 */
export function getKeyFromStorageUrl(storageUrl: string): string {
  return parseStorageUrl(storageUrl).key;
}

/**
 * Generate a signed URL for downloading/playing a file from S3
 * This allows mobile devices to access private files
 */
export async function createSignedPlaybackUrl(key: string): Promise<string> {
  if (!env.s3Bucket) {
    throw new Error('S3_BUCKET environment variable is not set.');
  }
  if (!env.s3AccessKeyId || !env.s3SecretAccessKey) {
    throw new Error('S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY must be set.');
  }

  const command = new GetObjectCommand({
    Bucket: env.s3Bucket,
    Key: key
  });

  // Use public S3 client so signed URL works for mobile devices
  const publicS3 = getPublicS3Client();
  const url = await getSignedUrl(publicS3, command, {
    expiresIn: 60 * 60 * 24 // 24 hours
  });

  return url;
}

/**
 * Download a file from S3 using credentials
 * @param key - S3 key (path to file)
 * @param bucket - Optional bucket name. If not provided, uses env.s3Bucket or extracts from storage URL
 */
export async function downloadFromS3(key: string, bucket?: string): Promise<Buffer> {
  const bucketName = bucket || env.s3Bucket;
  if (!bucketName) {
    throw new Error('S3_BUCKET environment variable is not set and no bucket provided.');
  }
  if (!env.s3AccessKeyId || !env.s3SecretAccessKey) {
    throw new Error('S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY must be set.');
  }

  console.log(`[S3] Downloading from bucket: ${bucketName}, key: ${key}`);
  
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: key
  });

  let response;
  try {
    response = await s3.send(command);
    console.log(`[S3] GetObject response received, ContentLength: ${response.ContentLength || 'unknown'}`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error(`[S3] GetObject failed: ${errorMessage}`);
    throw new Error(`S3 GetObject failed: ${errorMessage}`);
  }
  
  // Convert stream to buffer
  const chunks: Uint8Array[] = [];
  if (response.Body) {
    try {
      for await (const chunk of response.Body as any) {
        chunks.push(chunk);
      }
      console.log(`[S3] Downloaded ${chunks.length} chunks, total size: ${Buffer.concat(chunks).length} bytes`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error(`[S3] Stream reading failed: ${errorMessage}`);
      throw new Error(`Failed to read S3 stream: ${errorMessage}`);
    }
  } else {
    throw new Error('S3 response has no Body');
  }
  
  return Buffer.concat(chunks);
}


