# How to Find Your Node.js Service in Railway

## Step-by-Step Navigation

### 1. Go to Railway Dashboard
- Visit: https://railway.app
- Sign in to your account

### 2. Select Your Project
- You should see a list of projects
- Click on your project (might be named "VoxaNote" or similar)

### 3. Find Your Services
In the project view, you'll see your services listed. Look for:

**Services you should see:**
- **PostgreSQL** (database icon) - This is your database
- **Node.js/Backend** (code/server icon) - This is your backend service
  - Might be named: "backend", "server", "api", or the repo name

### 4. Click on the Node.js Service
- Click on the service that's NOT the PostgreSQL database
- This should open the service details

### 5. Go to Variables Tab
- Once in the service, look for tabs at the top:
  - **Deployments**
  - **Variables** ← Click this one
  - **Settings**
  - **Metrics**
  - etc.

### 6. Check for POSTGRES_URL
- In the Variables tab, look for `POSTGRES_URL`
- If it's missing, you need to add it

## What to Look For

**Service Icons:**
- 🗄️ Database icon = PostgreSQL (NOT this one)
- 💻 Code/Server icon = Node.js backend (THIS ONE)

**Service Names:**
- Usually named after your repo or "backend"/"server"
- NOT named "PostgreSQL" or "postgres"

## If You Can't Find It

1. **Check if service exists:**
   - Look at the top of the project page
   - You should see at least 2 services (PostgreSQL + Node.js)

2. **Check different views:**
   - Try "Architecture" view (shows all services)
   - Try "Settings" view (project-level settings)

3. **If no Node.js service exists:**
   - You may need to add one
   - Click "+ New" or "Add Service"
   - Select "Deploy from GitHub repo"
   - Choose your VoxaNote repository
   - Set root directory to `server`

## Quick Visual Guide

```
Railway Dashboard
└── Your Project
    ├── 🗄️ PostgreSQL (database - NOT this)
    └── 💻 Backend/Server (Node.js - THIS ONE)
        └── Variables Tab
            └── POSTGRES_URL (should be here)
```

## Need Help?

If you still can't find it, tell me:
1. How many services do you see?
2. What are they named?
3. What icons do they have?

I can guide you from there!
