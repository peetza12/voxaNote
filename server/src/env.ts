import dotenv from 'dotenv';
dotenv.config();

export const env = {
  port: parseInt(process.env.PORT || '4000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  // Railway's internal DNS (postgres.railway.internal) isn't resolving
  // Get the connection string from env vars
  let dbUrl = process.env.DATABASE_PUBLIC_URL ||
              process.env.DATABASE_URL || 
              process.env.POSTGRES_URL || 
              '';
  
  // If URL uses internal hostname that doesn't resolve, replace with public URL
  if (dbUrl && dbUrl.includes('postgres.railway.internal')) {
    // Extract credentials and replace hostname with public one
    try {
      const url = new URL(dbUrl);
      dbUrl = `postgresql://${url.username}:${url.password}@metro.proxy.rlwy.net:27075${url.pathname}`;
    } catch (e) {
      // Fallback to known working public URL
      dbUrl = 'postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@metro.proxy.rlwy.net:27075/railway';
    }
  }
  
  // Final fallback for production
  if (!dbUrl && process.env.NODE_ENV === 'production') {
    dbUrl = 'postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@metro.proxy.rlwy.net:27075/railway';
  }
  
  postgresUrl: dbUrl,
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


