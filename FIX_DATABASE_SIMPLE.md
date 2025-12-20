# Simple Fix for Database Connection Error

## The Problem
Your backend returns a 500 error because it can't connect to PostgreSQL.

## The Solution (Simplest Method)

### Option 1: Check Railway Logs (Easiest)

1. **Go to Railway**: https://railway.app
2. **Look for your backend service** (might be in a list, sidebar, or main area)
3. **Click on it** (or look for "Logs" or "Deployments" tab)
4. **Check the logs** - they'll show the exact database connection error

The logs will tell you:
- If `POSTGRES_URL` is missing
- If the database connection string is wrong
- If the database doesn't exist

### Option 2: Use Railway CLI (If UI is confusing)

If the web UI is hard to navigate, use the Railway CLI:

```bash
# Install Railway CLI (if not installed)
npm i -g @railway/cli

# Login
railway login

# Link to your project
railway link

# Check variables
railway variables

# Add POSTGRES_URL if missing
railway variables set POSTGRES_URL="your-postgres-url-here"
```

### Option 3: Check What's Actually Wrong

The error message shows: `"connect ECONNREFUSED ::1:5432"`

This means the backend is trying to connect to `localhost` (::1) instead of Railway's database.

**This usually means:**
- `POSTGRES_URL` environment variable is not set in Railway
- Or it's set incorrectly

## Quick Test

Run this to see what the backend is trying to connect to:

```bash
curl -v https://voxanote-production.up.railway.app/recordings 2>&1 | grep -i "error\|500"
```

## What You Need to Do

**The backend needs the `POSTGRES_URL` environment variable set.**

Since navigating Railway's UI is confusing, try:

1. **Look for any "Environment Variables" or "Config" section**
2. **Or use Railway CLI** (Option 2 above)
3. **Or check Railway's documentation** for how to set variables

## Alternative: Tell Me What You See

If you can describe what you see on the Railway page, I can give you exact click-by-click instructions.

For example:
- "I see a list of projects"
- "I see a dashboard with cards"
- "I see a sidebar on the left"
- "I see nothing but a blank page"

Any description helps!
