# Fix: postgres.railway.internal Not Resolving

## The Problem
Both `DATABASE_URL` and `POSTGRES_URL` are set, but Railway can't resolve `postgres.railway.internal`.

## The Issue
The hostname `postgres.railway.internal` assumes your PostgreSQL service is named "postgres", but Railway might have named it something else.

## Solution: Find the Correct Service Name

### Step 1: Check PostgreSQL Service Name

In Railway Architecture view:
1. Look at your PostgreSQL service node
2. **What is it actually named?** (might be "postgres", "PostgreSQL", "database", or something else)
3. Railway's internal DNS uses: `{service-name}.railway.internal`

### Step 2: Update Connection String

The connection string format should be:
```
postgresql://postgres:password@{SERVICE_NAME}.railway.internal:5432/railway
```

Where `{SERVICE_NAME}` is your actual PostgreSQL service name.

### Step 3: Update DATABASE_URL

1. **In Railway**, click "voxaNote" service → Variables tab
2. **Edit `DATABASE_URL`**
3. **Update the hostname** to match your PostgreSQL service name
4. **Save** (Railway will redeploy)

## Alternative: Use Railway's Auto-Provided Variable

Railway should automatically provide a `DATABASE_URL` when services are linked. Check:

1. **In Railway**, click "voxaNote" service → Variables tab
2. **Look for Railway-provided variables** (usually in a collapsible section)
3. **Check if there's a `DATABASE_URL`** that Railway added automatically
4. If yes, use that one instead

## Quick Test

After updating, test:
```bash
curl https://voxanote-production.up.railway.app/recordings
```

## Common Service Names

Railway might name PostgreSQL as:
- `postgres`
- `PostgreSQL` 
- `database`
- `db`
- Or the name you gave it when creating

Check the Architecture view to see the exact name!
