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
 * Extract S3 key from a storage URL
 * Handles formats like:
 * - https://storage.railway.app/bucket/key
 * - https://bucket.s3.region.amazonaws.com/key
 */
export function getKeyFromStorageUrl(storageUrl: string): string {
  try {
    const url = new URL(storageUrl);
    // Railway format: https://storage.railway.app/bucket/key
    if (url.pathname.startsWith('/')) {
      const parts = url.pathname.split('/').filter(p => p);
      // First part is bucket, rest is key
      return parts.slice(1).join('/');
    }
    // AWS format: https://bucket.s3.region.amazonaws.com/key
    return url.pathname.substring(1); // Remove leading /
  } catch {
    // If URL parsing fails, try to extract key from common patterns
    const match = storageUrl.match(/\/([^/]+\/.+)$/);
    return match ? match[1] : storageUrl;
  }
}

/**
 * Download a file from S3 using credentials
 */
export async function downloadFromS3(key: string): Promise<Buffer> {
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

  const response = await s3.send(command);
  
  // Convert stream to buffer
  const chunks: Uint8Array[] = [];
  if (response.Body) {
    for await (const chunk of response.Body as any) {
      chunks.push(chunk);
    }
  }
  
  return Buffer.concat(chunks);
}


