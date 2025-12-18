import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
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
  const key = `recordings/${userId || 'anon'}/${crypto.randomUUID()}.m4a`;
  const command = new PutObjectCommand({
    Bucket: env.s3Bucket,
    Key: key,
    ContentType: 'audio/m4a'
  });

  // Use public S3 client so signed URL uses network IP from the start
  // This ensures the signature is valid for the URL mobile devices will use
  const publicS3 = getPublicS3Client();
  const url = await getSignedUrl(publicS3, command, { expiresIn: 60 * 15 });
  
  return { key, url };
}

export function getPublicUrlFromKey(key: string): string {
  // Use public endpoint for playback URLs so mobile devices can access them
  const endpoint = (env.s3PublicEndpoint || env.s3Endpoint).replace(/\/$/, '');
  if (endpoint) {
    return `${endpoint}/${env.s3Bucket}/${key}`;
  }
  return `https://${env.s3Bucket}.s3.${env.s3Region}.amazonaws.com/${key}`;
}


