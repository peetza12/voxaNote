# Quick Deploy Commands - Copy & Paste

Exact commands to run for deployment.

---

## 🤖 Android - Quick Setup

### 1. Setup Signing (First time only)
```bash
cd /Users/peterwylie/VoxaNote
./setup-android-signing.sh
```

### 2. Update Application ID (IMPORTANT!)
Edit `/Users/peterwylie/VoxaNote/mobile_flutter/android/app/build.gradle.kts`:
```kotlin
applicationId = "com.yourcompany.voxanote"  // Change from com.example.voxa_note_mobile
```

### 3. Build Release Bundle
```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter clean
flutter pub get
flutter build appbundle --release
```

### 4. Find Your AAB File
```bash
open /Users/peterwylie/VoxaNote/mobile_flutter/build/app/outputs/bundle/release/
```
The file `app-release.aab` is what you upload to Google Play.

---

## 📱 iOS - Quick Setup

### 1. Open Xcode
```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter/ios
open Runner.xcworkspace
```

### 2. In Xcode:
1. Select **Runner** target
2. Go to **Signing & Capabilities**
3. Select your **Team** (Apple Developer account)
4. Update **Bundle Identifier** to match App Store Connect (e.g., `com.yourcompany.voxanote`)
5. Check **"Automatically manage signing"**

### 3. Update Version (if needed)
- General tab → Version: `0.1.0`
- Build: `1`

### 4. Create Archive
1. Select **"Any iOS Device"** (not a simulator)
2. Product → **Archive**
3. Wait for archive to complete

### 5. Upload to App Store
1. Window → **Organizer**
2. Select your archive
3. Click **"Distribute App"**
4. Choose **"App Store Connect"**
5. Click **"Upload"**
6. Follow the wizard

---

## 🔧 Important: Update API URLs for Production

Before submitting, update your backend API URL in the app:

### Option 1: Update in code
Edit `/Users/peterwylie/VoxaNote/mobile_flutter/lib/services/api_client.dart`:
```dart
// Change from localhost to your production URL
return 'https://api.yourdomain.com';
```

### Option 2: Use environment variables
For iOS, update Xcode scheme with:
```
--dart-define=API_BASE_URL=https://api.yourdomain.com
```

For Android, build with:
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

---

## ✅ Pre-Submission Checklist

### Both Platforms:
- [ ] App tested on real devices
- [ ] All features working (record, upload, transcribe, chat)
- [ ] Backend deployed and accessible
- [ ] API URLs updated for production
- [ ] Privacy policy URL is live
- [ ] Support email/URL is valid

### iOS Specific:
- [ ] Bundle ID matches App Store Connect
- [ ] Signing configured correctly
- [ ] Archive created successfully
- [ ] Uploaded to App Store Connect
- [ ] Screenshots uploaded
- [ ] Description filled in
- [ ] Privacy policy URL added

### Android Specific:
- [ ] Application ID updated (not com.example.*)
- [ ] Keystore created and secured
- [ ] AAB built successfully
- [ ] Uploaded to Play Console
- [ ] Screenshots uploaded
- [ ] Description filled in
- [ ] Data safety form completed
- [ ] Privacy policy URL added

---

## 🚨 Common Issues & Fixes

### Android: "Keystore file not found"
```bash
cd /Users/peterwylie/VoxaNote
./setup-android-signing.sh
```

### Android: "Application ID must be unique"
Change `applicationId` in `android/app/build.gradle.kts` to something unique like `com.yourcompany.voxanote`

### iOS: "No signing certificate found"
- Go to Xcode → Preferences → Accounts
- Add your Apple ID
- Select your team in Signing & Capabilities

### iOS: "Bundle ID already exists"
- Change Bundle ID in Xcode to something unique
- Or use the existing app in App Store Connect

### Both: "Connection timeout" in production
- Update API URLs from localhost to production domain
- Ensure backend is deployed and accessible
- Check CORS settings on backend

---

## 📞 Need Help?

- **iOS Issues:** Check [Apple Developer Forums](https://developer.apple.com/forums/)
- **Android Issues:** Check [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- **Flutter Issues:** Check [Flutter Documentation](https://flutter.dev/docs)

