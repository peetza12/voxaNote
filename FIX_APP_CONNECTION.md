# Fix: App Cannot Connect to Server

## The Problem

Your app is trying to connect to `localhost:4000` (development server) instead of your Railway production backend.

## The Solution

You need to rebuild the app with the production API URL.

---

## For iOS (Xcode)

### Option 1: Build from Terminal (Recommended)

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter clean
flutter build ios --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

Then open in Xcode and run:
```bash
open ios/Runner.xcworkspace
```

### Option 2: Set in Xcode Build Settings

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** project in the navigator
3. Select the **Runner** target
4. Go to **Build Settings** tab
5. Search for "Other Swift Flags" or "Other C Flags"
6. Add: `-DAPI_BASE_URL=https://voxanote-production.up.railway.app`

Or use **Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables**:
- Add: `API_BASE_URL` = `https://voxanote-production.up.railway.app`

---

## For Android

### Build from Terminal

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter clean
flutter build apk --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

Or for App Bundle:
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

### Install on Device

```bash
flutter install --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

---

## Quick Test Commands

### Test iOS (Simulator or Device)

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter run --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

### Test Android (Device or Emulator)

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter run --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
```

---

## Verify It's Working

After rebuilding, the app should:
1. ✅ Connect to `https://voxanote-production.up.railway.app`
2. ✅ No "Cannot connect to server" error
3. ✅ Be able to record and upload voice notes
4. ✅ Work without a local dev server running

---

## Why This Happened

The app was built without the `--dart-define=API_BASE_URL` flag, so it used the development fallback URL (`localhost:4000` or `192.168.5.89:4000`).

The `api_client.dart` code checks for `API_BASE_URL` first, then falls back to development URLs if not set.

---

## Production API URL

**Your Railway backend:** `https://voxanote-production.up.railway.app`

Always use this URL when building production/release versions of your app.
