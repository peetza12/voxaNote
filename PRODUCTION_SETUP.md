# Production Setup Guide

This guide explains how to deploy VoxaNote so the mobile app works independently without requiring a local development server.

## Overview

VoxaNote consists of two parts:
1. **Backend Server** - Node.js API that handles recordings, transcription, and AI features
2. **Mobile App** - Flutter app that connects to the backend

For production, you need to:
1. Deploy the backend server to a cloud provider
2. Configure the mobile app to use the production backend URL
3. Build and deploy the mobile app

---

## Step 1: Deploy Backend Server

You need to deploy the backend server to a cloud provider. Here are recommended options:

### Option A: Railway (Easiest)
1. Go to [railway.app](https://railway.app)
2. Create a new project
3. Connect your GitHub repository
4. Add services:
   - **Postgres** (for database)
   - **Node.js** (for your backend)
5. Set environment variables (see `server/.env` template)
6. Deploy

### Option B: Render
1. Go to [render.com](https://render.com)
2. Create a new Web Service
3. Connect your GitHub repository
4. Add a Postgres database
5. Set environment variables
6. Deploy

### Option C: AWS/DigitalOcean/Heroku
- Follow standard Node.js deployment procedures
- Ensure you have Postgres and S3-compatible storage

### Required Environment Variables

Set these in your cloud provider:

```bash
PORT=4000
NODE_ENV=production

# Postgres (from your cloud provider)
POSTGRES_URL=postgres://user:pass@host:5432/dbname

# OpenAI
OPENAI_API_KEY=your-openai-api-key

# S3-compatible storage (AWS S3, or cloud storage)
S3_ENDPOINT=https://s3.amazonaws.com  # or your S3-compatible endpoint
S3_PUBLIC_ENDPOINT=https://s3.amazonaws.com  # public endpoint for signed URLs
S3_REGION=us-east-1
S3_ACCESS_KEY_ID=your-access-key
S3_SECRET_ACCESS_KEY=your-secret-key
S3_BUCKET=voxa-note-audio

MAX_RECORDING_SECONDS=3600
```

### Get Your Production API URL

After deployment, you'll get a URL like:
- `https://your-app.railway.app`
- `https://your-app.onrender.com`
- `https://api.yourdomain.com`

**This is your production API URL** - you'll use it in the next step.

---

## Step 2: Configure Mobile App for Production

### For iOS (App Store)

1. **Build with production API URL:**
   ```bash
   cd mobile_flutter
   flutter build ios --release \
     --dart-define=API_BASE_URL=https://your-production-api-url.com
   ```

2. **Or set it in Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Go to Product → Scheme → Edit Scheme
   - Under "Run" → "Arguments" → "Arguments Passed On Launch"
   - Add: `--dart-define=API_BASE_URL=https://your-production-api-url.com`

3. **Archive and upload** as normal

### For Android (Google Play)

1. **Build with production API URL:**
   ```bash
   cd mobile_flutter
   flutter build appbundle --release \
     --dart-define=API_BASE_URL=https://your-production-api-url.com
   ```

2. **Upload the AAB** to Google Play Console

---

## Step 3: Update Build Scripts (Optional but Recommended)

Create build scripts to make this easier:

### `build-ios-release.sh`
```bash
#!/bin/bash
API_URL="${1:-https://your-production-api-url.com}"
cd mobile_flutter
flutter build ios --release --dart-define=API_BASE_URL=$API_URL
echo "✅ iOS build complete with API URL: $API_URL"
```

### `build-android-release.sh`
```bash
#!/bin/bash
API_URL="${1:-https://your-production-api-url.com}"
cd mobile_flutter
flutter build appbundle --release --dart-define=API_BASE_URL=$API_URL
echo "✅ Android build complete with API URL: $API_URL"
```

Usage:
```bash
./build-ios-release.sh https://your-api.railway.app
./build-android-release.sh https://your-api.railway.app
```

---

## Quick Start: Deploy to Railway (Recommended)

1. **Install Railway CLI:**
   ```bash
   npm i -g @railway/cli
   railway login
   ```

2. **Deploy backend:**
   ```bash
   cd server
   railway init
   railway up
   ```

3. **Add Postgres:**
   ```bash
   railway add postgresql
   railway link
   ```

4. **Set environment variables:**
   ```bash
   railway variables set OPENAI_API_KEY=your-key
   railway variables set S3_ENDPOINT=https://s3.amazonaws.com
   # ... set all other variables
   ```

5. **Get your API URL:**
   ```bash
   railway domain
   # This gives you: https://your-app.railway.app
   ```

6. **Build mobile app with that URL:**
   ```bash
   cd mobile_flutter
   flutter build ios --release --dart-define=API_BASE_URL=https://your-app.railway.app
   flutter build appbundle --release --dart-define=API_BASE_URL=https://your-app.railway.app
   ```

---

## Important Notes

1. **HTTPS Required**: Production APIs must use HTTPS (not HTTP)
2. **CORS**: Your backend already has CORS enabled, so this should work
3. **S3 Storage**: Make sure your S3 bucket is publicly accessible or use signed URLs (already implemented)
4. **Database**: Run migrations on your production database:
   ```bash
   psql "$POSTGRES_URL" -f migrations/001_init.sql
   ```

---

## Testing Production Build Locally

Before submitting to app stores, test with production URL:

```bash
# iOS
flutter run --release --dart-define=API_BASE_URL=https://your-api-url.com

# Android
flutter run --release --dart-define=API_BASE_URL=https://your-api-url.com
```

---

## Troubleshooting

**App shows "Cannot connect to server":**
- Verify your backend is deployed and accessible
- Check the API URL is correct (use `curl https://your-api-url.com/health`)
- Ensure you built with `--dart-define=API_BASE_URL=...`

**401/500 errors:**
- Check backend logs
- Verify environment variables are set correctly
- Ensure database migrations are run

**CORS errors:**
- Backend already has CORS enabled, but verify it's working
- Check browser console for specific CORS errors
