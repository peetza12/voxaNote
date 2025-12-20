# Fix Connection String - Use Correct Service Name

## The Problem
Your PostgreSQL service is named **"Postgres"** (capital P), but the connection string uses `postgres.railway.internal` (lowercase).

Railway's internal DNS uses the exact service name, so it should be `Postgres.railway.internal`.

## The Fix

### Update DATABASE_URL in Railway

1. **In Railway**, click your **"voxaNote" service**
2. **Go to "Variables" tab**
3. **Find `DATABASE_URL`** and click to edit it
4. **Change the hostname from:**
   ```
   postgres.railway.internal
   ```
   **To:**
   ```
   Postgres.railway.internal
   ```
   (Capital P to match your service name)

5. **The full connection string should be:**
   ```
   postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJ0ggL@Postgres.railway.internal:5432/railway
   ```

6. **Save** - Railway will automatically redeploy

### Also Update POSTGRES_URL

Do the same for `POSTGRES_URL`:
- Change `postgres.railway.internal` → `Postgres.railway.internal`

## After Updating

Wait 1-2 minutes for Railway to redeploy, then test:
```bash
curl https://voxanote-production.up.railway.app/recordings
```

Should return: `[]` instead of 500 error!
