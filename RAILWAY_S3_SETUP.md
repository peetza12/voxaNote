# Setting Up S3 Storage on Railway

Your VoxaNote app requires S3-compatible storage to upload audio recordings. You have several options:

## Option 1: AWS S3 (Recommended for Production)

1. **Create an AWS Account** (if you don't have one):
   - Go to https://aws.amazon.com/
   - Sign up for a free tier account

2. **Create an S3 Bucket**:
   - Go to AWS Console → S3
   - Click "Create bucket"
   - Name: `voxanote-audio` (or any name you prefer)
   - Region: `us-east-1` (or your preferred region)
   - Uncheck "Block all public access" (or configure CORS later)
   - Click "Create bucket"

3. **Create IAM User for API Access**:
   - Go to AWS Console → IAM → Users
   - Click "Create user"
   - Name: `voxanote-s3-user`
   - Check "Provide user access to the AWS Management Console" → **Skip this**
   - Click "Next"
   - Click "Attach policies directly"
   - Search for and select: `AmazonS3FullAccess` (or create a custom policy with only PutObject, GetObject permissions)
   - Click "Create user"
   - Click on the user → "Security credentials" tab
   - Click "Create access key"
   - Choose "Application running outside AWS"
   - Click "Create access key"
   - **SAVE THE ACCESS KEY ID AND SECRET ACCESS KEY** (you won't see the secret again)

4. **Configure CORS on S3 Bucket** (for mobile uploads):
   - Go to your S3 bucket → Permissions tab → CORS
   - Add this configuration:
   ```json
   [
     {
       "AllowedHeaders": ["*"],
       "AllowedMethods": ["PUT", "GET", "HEAD"],
       "AllowedOrigins": ["*"],
       "ExposeHeaders": ["ETag"],
       "MaxAgeSeconds": 3000
     }
   ]
   ```

5. **Add Environment Variables to Railway**:
   - Go to your Railway project → Node.js service → Variables tab
   - Add these variables:
     ```
     S3_BUCKET=voxanote-audio
     S3_REGION=us-east-1
     S3_ACCESS_KEY_ID=<your-access-key-id>
     S3_SECRET_ACCESS_KEY=<your-secret-access-key>
     ```
   - **Note**: Do NOT set `S3_ENDPOINT` or `S3_PUBLIC_ENDPOINT` for AWS S3 (leave them empty)

## Option 2: MinIO on Railway (Self-Hosted)

1. **Add MinIO Service to Railway**:
   - In your Railway project, click "+ New" → "Database" → "Add MinIO"
   - Or use Railway's template: https://railway.app/template/minio

2. **Create a Bucket**:
   - Once MinIO is deployed, get the MinIO endpoint URL from Railway
   - Access the MinIO console (usually at `<minio-url>/console`)
   - Login with the credentials Railway provides
   - Create a bucket named `voxa-note-audio`

3. **Add Environment Variables to Railway**:
   - Go to your Node.js service → Variables tab
   - Add:
     ```
     S3_BUCKET=voxa-note-audio
     S3_ENDPOINT=<minio-internal-endpoint> (from Railway MinIO service)
     S3_PUBLIC_ENDPOINT=<minio-public-endpoint> (for mobile uploads)
     S3_REGION=us-east-1
     S3_ACCESS_KEY_ID=<minio-access-key>
     S3_SECRET_ACCESS_KEY=<minio-secret-key>
     ```

## Option 3: Other S3-Compatible Services

You can also use:
- **Supabase Storage**: S3-compatible API
- **Cloudflare R2**: S3-compatible, no egress fees
- **DigitalOcean Spaces**: S3-compatible

For any of these, you'll need:
- `S3_BUCKET`: Your bucket name
- `S3_ENDPOINT`: The service endpoint URL
- `S3_PUBLIC_ENDPOINT`: Public URL for mobile uploads (may be same as endpoint)
- `S3_REGION`: Region (if applicable)
- `S3_ACCESS_KEY_ID`: Your access key
- `S3_SECRET_ACCESS_KEY`: Your secret key

## Verify Setup

After adding the environment variables, Railway will automatically redeploy. Test by:

```bash
curl -X POST https://voxanote-production.up.railway.app/recordings \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","durationSec":10}'
```

You should get a response with `recording` and `uploadUrl` fields. If you get an error about S3 configuration, check that all variables are set correctly.

## Troubleshooting

- **400 Bad Request on upload**: Check that CORS is configured correctly
- **403 Forbidden**: Check that your access keys have PutObject permission
- **Invalid bucket name**: Ensure `S3_BUCKET` matches your actual bucket name exactly
