# Set POSTGRES_URL in Railway Node.js Service

## The Problem
Your backend is still trying to connect to `localhost:5432` instead of Railway's PostgreSQL.

## The Solution

You need to set `POSTGRES_URL` in your **Node.js service** (not the PostgreSQL service).

### Step-by-Step:

1. **In Railway dashboard**, click on your **"voxaNote" service** (the Node.js backend, NOT PostgreSQL)

2. **Go to "Variables" tab**

3. **Add a new variable:**
   - Click **"New Variable"** or **"Add Variable"** button
   - **Name:** `POSTGRES_URL`
   - **Value:** `postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@postgres.railway.internal:5432/railway`
   - Click **"Save"** or **"Add"**

4. **Railway will automatically redeploy** your service

5. **Wait for deployment to complete** (check the "Deployments" tab)

6. **Test:**
   ```bash
   curl https://voxanote-production.up.railway.app/recordings
   ```
   Should return: `[]` (empty array) instead of 500 error

## Important Notes

- Use the **internal URL** (`postgres.railway.internal`) - this works from within Railway's network
- Set it in the **Node.js service**, not the PostgreSQL service
- The variable name must be exactly: `POSTGRES_URL` (all caps)

## Alternative: Using Railway CLI

If you have Railway CLI installed:

```bash
railway variables set POSTGRES_URL="postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@postgres.railway.internal:5432/railway" --service voxaNote
```

## Verify It's Set

After setting, check:

```bash
railway variables --service voxaNote
```

Should show `POSTGRES_URL` in the list.
