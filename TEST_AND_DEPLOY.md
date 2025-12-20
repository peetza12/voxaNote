# Test and Deploy Guide - Production Builds

Your production API URL: **`https://voxanote-production.up.railway.app`**

---

## Step 1: Build Apps with Production API URL

### Build iOS App

```bash
cd mobile_flutter
flutter clean
flutter build ios --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

**What this does:**
- Cleans previous builds
- Builds iOS release version
- Configures app to use your Railway backend

### Build Android App

```bash
cd mobile_flutter
flutter clean
flutter build appbundle --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

**What this does:**
- Cleans previous builds
- Builds Android App Bundle (AAB)
- Configures app to use your Railway backend

**AAB Location:** `mobile_flutter/build/app/outputs/bundle/release/app-release.aab`

---

## Step 2: Test Locally Before Deployment

### Test iOS App Locally

1. **Open Xcode:**
   ```bash
   cd mobile_flutter
   open ios/Runner.xcworkspace
   ```

2. **In Xcode:**
   - Select a device or simulator from the device dropdown (top toolbar)
   - Click the **Play button** (▶️) or press `Cmd + R` to run
   - The app will install and launch on your device/simulator

3. **Test the app:**
   - ✅ Record a voice note
   - ✅ Upload and process it
   - ✅ Check that it connects to `https://voxanote-production.up.railway.app`
   - ✅ Verify transcription and AI features work

4. **Check logs in Xcode:**
   - Open the Debug Console (View → Debug Area → Show Debug Area)
   - Look for any API connection errors
   - Verify API calls are going to your Railway URL

### Test Android App Locally

1. **Connect your Android device** or start an emulator:
   ```bash
   # Check connected devices
   flutter devices
   ```

2. **Install and run the app:**
   ```bash
   cd mobile_flutter
   flutter install --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
   ```

   Or build and install separately:
   ```bash
   flutter build apk --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
   flutter install
   ```

3. **Test the app:**
   - ✅ Record a voice note
   - ✅ Upload and process it
   - ✅ Check that it connects to `https://voxanote-production.up.railway.app`
   - ✅ Verify transcription and AI features work

4. **Check logs:**
   ```bash
   flutter logs
   ```
   - Look for any API connection errors
   - Verify API calls are going to your Railway URL

---

## Step 3: Deploy to App Stores

### Deploy iOS to App Store

1. **Archive in Xcode:**
   ```bash
   cd mobile_flutter
   open ios/Runner.xcworkspace
   ```
   - In Xcode: **Product → Archive**
   - Wait for archive to complete

2. **Distribute to App Store:**
   - In the Organizer window (opens automatically after archive):
     - Select your archive
     - Click **"Distribute App"**
     - Choose **"App Store Connect"**
     - Follow the prompts to upload

3. **In App Store Connect:**
   - Go to your app
   - Wait for processing (usually 5-10 minutes)
   - Select the new build
   - Submit for review

### Deploy Android to Google Play

1. **Upload AAB to Google Play Console:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Select your app
   - Go to **"Production"** (or "Internal testing")
   - Click **"Create new release"**
   - Upload: `mobile_flutter/build/app/outputs/bundle/release/app-release.aab`
   - Fill in release notes
   - Submit for review

---

## Step 4: Test After Deployment

### Test iOS App from App Store

1. **Wait for App Store approval** (usually 24-48 hours)
2. **Install from App Store** on a test device
3. **Test independently:**
   - ✅ Open app (no local dev server needed)
   - ✅ Record a voice note
   - ✅ Upload and process
   - ✅ Verify it connects to Railway backend
   - ✅ Test all features work

### Test Android App from Google Play

1. **Wait for Google Play approval** (usually a few hours to 1 day)
2. **Install from Google Play** on a test device
3. **Test independently:**
   - ✅ Open app (no local dev server needed)
   - ✅ Record a voice note
   - ✅ Upload and process
   - ✅ Verify it connects to Railway backend
   - ✅ Test all features work

---

## Verification Checklist

After deployment, verify:

- [ ] App installs successfully from store
- [ ] App opens without errors
- [ ] Can record voice notes
- [ ] Upload works (connects to Railway)
- [ ] Transcription completes successfully
- [ ] AI chat features work
- [ ] No local dev server required
- [ ] Works on different networks (WiFi, cellular)

---

## Troubleshooting

### App can't connect to backend

1. **Check Railway is online:**
   ```bash
   curl https://voxanote-production.up.railway.app/health
   ```
   Should return: `{"status":"ok"}`

2. **Verify API URL in app:**
   - Check build logs to confirm `API_BASE_URL` was set correctly
   - Rebuild if needed with correct URL

3. **Check Railway logs:**
   - Go to Railway dashboard
   - Check service logs for errors

### Build fails

- Make sure Flutter is in your PATH
- Run `flutter doctor` to check setup
- Clean and rebuild: `flutter clean && flutter pub get`

### App Store/Play Store rejection

- Check that all required permissions are declared
- Verify privacy policy URL is set
- Ensure app works without local dev server

---

## Quick Reference

**Production API URL:** `https://voxanote-production.up.railway.app`

**Build Commands:**
```bash
# iOS
flutter build ios --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app

# Android
flutter build appbundle --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

**Test Locally:**
```bash
# iOS - Open in Xcode and run
open ios/Runner.xcworkspace

# Android - Install on device
flutter install --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```
