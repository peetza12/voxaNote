import dotenv from 'dotenv';
dotenv.config();

export const env = {
  port: parseInt(process.env.PORT || '4000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  postgresUrl: process.env.POSTGRES_URL || '',
  openaiApiKey: process.env.OPENAI_API_KEY || '',
  s3Endpoint: process.env.S3_ENDPOINT || '',
  s3PublicEndpoint: process.env.S3_PUBLIC_ENDPOINT || '',
  s3Region: process.env.S3_REGION || 'us-east-1',
  s3AccessKeyId: process.env.S3_ACCESS_KEY_ID || '',
  s3SecretAccessKey: process.env.S3_SECRET_ACCESS_KEY || '',
  s3Bucket: process.env.S3_BUCKET || '',
  maxRecordingSeconds: parseInt(process.env.MAX_RECORDING_SECONDS || '3600', 10)
};

if (!env.postgresUrl) {
  // eslint-disable-next-line no-console
  console.warn('POSTGRES_URL is not set');
}


