# Add PostgreSQL to Railway - Step by Step

## The Problem
Your Railway project only has the Node.js service ("voxaNote") but no PostgreSQL database. That's why you're getting the 500 error.

## The Solution

### Step 1: Add PostgreSQL Service

1. **In Railway dashboard** (where you see the "voxaNote" service):
   - Look for a **"+ New"** button (usually top right or in the architecture view)
   - Or look for **"Add Service"** or **"Create"** button
   - Click it

2. **Select Database**:
   - You should see options like:
     - "Database"
     - "PostgreSQL"
     - "Add PostgreSQL"
   - Click on **"PostgreSQL"** or **"Add PostgreSQL"**

3. **Wait for it to deploy**:
   - Railway will automatically create a PostgreSQL database
   - It will appear as a new service in your architecture view

### Step 2: Get the PostgreSQL Connection URL

Once PostgreSQL is added:

1. **Click on the PostgreSQL service** (the new database node)
2. **Go to "Variables" tab** (or "Connect" tab)
3. **Copy the `POSTGRES_URL`** or `DATABASE_URL`
   - It will look like: `postgresql://postgres:password@hostname:5432/railway`

### Step 3: Set POSTGRES_URL in Your Node.js Service

1. **Click back on your "voxaNote" service**
2. **Go to "Variables" tab**
3. **Click "New Variable"** or **"Add Variable"**
4. **Add:**
   - **Name:** `POSTGRES_URL`
   - **Value:** (paste the URL from Step 2)
5. **Save**

### Step 4: Run Database Migrations

After setting POSTGRES_URL, you need to create the database tables:

**Option A: Using Railway's Database Console**

1. Click on your **PostgreSQL service**
2. Go to **"Data"** or **"Query"** tab
3. Run this SQL:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
```

4. Then copy/paste the contents of `server/migrations/001_init.sql`

**Option B: Using psql from Terminal**

```bash
# Get the POSTGRES_URL from Railway
railway variables --service postgres

# Run migrations
cd server
psql "$POSTGRES_URL" -f migrations/001_init.sql
```

### Step 5: Redeploy Your Backend

After setting POSTGRES_URL:
1. Railway should automatically redeploy
2. Or manually trigger a redeploy
3. Check the logs to verify it connects

## Quick Test

After everything is set up:

```bash
curl https://voxanote-production.up.railway.app/recordings
```

Should return: `[]` (empty array) instead of a 500 error.

## Alternative: Use Railway CLI

If the UI is still confusing, you can add PostgreSQL via CLI:

```bash
# Add PostgreSQL service
railway add postgresql

# Get the connection URL
railway variables --service postgres

# Set it in your Node.js service
railway variables set POSTGRES_URL="the-url-from-above"
```
