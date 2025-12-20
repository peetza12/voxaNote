# Quick Storage Setup (2 Minutes, FREE)

Railway has **built-in FREE storage** that works perfectly. No AWS account needed!

## Cost: $0/month (FREE)

Railway Storage Buckets are included with your Railway plan.

## Setup Steps (Minimal Clicks)

### Option A: Automated Script (Easiest)

1. Run: `./setup-railway-storage.sh`
2. Follow the prompts (it will guide you through 2 clicks in Railway)
3. Done!

### Option B: Manual (If script doesn't work)

1. **Go to Railway**: https://railway.app/project
2. **Click your project** → Click **"+ New"** → Click **"Bucket"**
3. **Name it**: `voxanote-audio` → Click **"Create"**
4. **Click the bucket** → Click **"Credentials" tab**
5. **Copy these 4 values**:
   - `ENDPOINT`
   - `ACCESS_KEY_ID`
   - `SECRET_ACCESS_KEY`
   - `BUCKET` (full name)

6. **Go to your Node.js service** → **Variables tab** → Add:
   ```
   S3_ENDPOINT=<paste ENDPOINT>
   S3_PUBLIC_ENDPOINT=<paste ENDPOINT>
   S3_REGION=us-east-1
   S3_ACCESS_KEY_ID=<paste ACCESS_KEY_ID>
   S3_SECRET_ACCESS_KEY=<paste SECRET_ACCESS_KEY>
   S3_BUCKET=<paste BUCKET>
   ```

Railway will auto-redeploy. Test by uploading a recording in your app!

## That's It!

No AWS, no external services, no credit cards. Railway handles everything.
