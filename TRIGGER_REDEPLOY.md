# Trigger Railway Redeploy

## The Problem
You set POSTGRES_URL but the backend is still using localhost. Railway may not have redeployed automatically.

## Solution: Manually Trigger Redeploy

### Option 1: Via Railway Dashboard

1. **Go to your "voxaNote" service** in Railway
2. **Go to "Deployments" tab**
3. **Click "Redeploy"** or **"Deploy Latest"** button
4. **Wait for deployment to complete**

### Option 2: Push a Commit (Triggers Auto-Deploy)

If Railway is connected to GitHub:

```bash
cd /Users/peterwylie/VoxaNote
git commit --allow-empty -m "Trigger Railway redeploy"
git push origin main
```

This will trigger a new deployment with the updated environment variables.

### Option 3: Check Variable is Set Correctly

1. **In Railway**, click "voxaNote" service
2. **Variables tab** - verify:
   - Variable name: `POSTGRES_URL` (exactly, all caps)
   - Value: `postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@postgres.railway.internal:5432/railway`
   - Make sure it's in the **voxaNote service**, not PostgreSQL service

### Option 4: Check Railway Logs

1. **Click "voxaNote" service**
2. **Go to "Logs" or "Deploy Logs" tab**
3. **Look for:**
   - `POSTGRES_URL is not set` warning (means variable isn't being read)
   - Database connection errors
   - Any other errors

## After Redeploy

Test again:
```bash
curl https://voxanote-production.up.railway.app/recordings
```

Should return: `[]` instead of 500 error.
