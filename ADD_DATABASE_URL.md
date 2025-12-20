# Add DATABASE_URL to Railway

## The Problem
Railway isn't automatically providing `DATABASE_URL` even though PostgreSQL is added. The backend needs this to connect.

## Solution: Add DATABASE_URL Manually

### Step 1: Get the Correct Connection String

In Railway:
1. **Click on your PostgreSQL service** (not voxaNote)
2. **Go to "Variables" tab**
3. **Copy the `DATABASE_URL`** value (or `POSTGRES_URL` if DATABASE_URL doesn't exist)
4. It should look like: `postgresql://postgres:password@postgres.railway.internal:5432/railway`

### Step 2: Add DATABASE_URL to Node.js Service

1. **Click on your "voxaNote" service** (Node.js backend)
2. **Go to "Variables" tab**
3. **Click "New Variable"** or **"Add Variable"**
4. **Add:**
   - **Name:** `DATABASE_URL`
   - **Value:** (paste the connection string from PostgreSQL service)
   - Use the **internal URL** (`postgres.railway.internal`) - this works from within Railway's network
5. **Save**

### Step 3: Verify Both Services Are in Same Project

Make sure:
- PostgreSQL service and voxaNote service are in the **same project** ("rare-purpose")
- Both are in the **same environment** ("production")

### Step 4: Redeploy

After adding DATABASE_URL:
- Railway should auto-redeploy
- Or manually trigger redeploy from Deployments tab
- Wait for deployment to complete

### Step 5: Test

```bash
curl https://voxanote-production.up.railway.app/recordings
```

Should return: `[]` instead of 500 error.

## Why This Happens

Railway should automatically provide `DATABASE_URL` when you add PostgreSQL, but sometimes:
- Services aren't properly linked
- Railway needs both services in the same project/environment
- Manual addition is needed

Adding `DATABASE_URL` manually should fix it!
