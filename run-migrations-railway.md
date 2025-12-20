# Run Database Migrations in Railway

## Option 1: Using Railway's Database Console (Easiest)

1. **In Railway dashboard**, click on your **PostgreSQL service** (the database)

2. **Go to "Data" or "Query" tab**
   - Look for tabs at the top of the service details
   - Click "Data" or "Query" or "SQL Editor"

3. **Run the SQL commands:**

   First, enable the required extensions:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

4. **Then run the full migration:**
   - Copy the contents of `server/migrations/001_init.sql`
   - Paste it into the SQL editor
   - Click "Run" or "Execute"

## Option 2: Using Railway CLI (Command Line)

```bash
# Get the POSTGRES_URL
railway variables --service postgres

# Run migrations
cd /Users/peterwylie/VoxaNote/server
psql "$(railway variables --service postgres | grep POSTGRES_URL | awk '{print $2}')" -f migrations/001_init.sql
```

Or manually:
```bash
# Get the URL first
railway variables --service postgres

# Then use it (replace YOUR_URL with the actual URL)
cd /Users/peterwylie/VoxaNote/server
psql "YOUR_POSTGRES_URL_HERE" -f migrations/001_init.sql
```

## Option 3: Using psql Directly

If you have the POSTGRES_URL:

```bash
cd /Users/peterwylie/VoxaNote/server
psql "postgresql://postgres:password@hostname:5432/railway" -f migrations/001_init.sql
```

## Verify It Worked

After running migrations, test:

```bash
curl https://voxanote-production.up.railway.app/recordings
```

Should return: `[]` (empty array) instead of a 500 error.
