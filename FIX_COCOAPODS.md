# Fix CocoaPods Error for iOS Build

You're getting this error because CocoaPods dependencies need to be installed.

## Quick Fix (2 steps)

### Step 1: Install CocoaPods (if not already installed)

Run this in your terminal:

```bash
sudo gem install cocoapods
```

You'll be prompted for your password. Enter it and wait for installation to complete.

### Step 2: Install iOS Dependencies

Run this in your terminal:

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter/ios
pod install
```

This will:
- Read the `Podfile`
- Download and install all required iOS dependencies
- Create the `Pods` directory and `Manifest.lock` file

## After pod install completes

Once `pod install` finishes successfully:

1. **Close Xcode** if it's open
2. **Reopen the workspace** (not the project):
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter
   open ios/Runner.xcworkspace
   ```
   ⚠️ **Important**: Open `Runner.xcworkspace`, NOT `Runner.xcodeproj`

3. **Build and run** in Xcode:
   - Select your device/simulator
   - Click the Play button (▶️) or press `Cmd + R`

## Alternative: Use the install script

You can also use the provided script:

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter/ios
chmod +x install-pods.sh
./install-pods.sh
```

This script will:
- Check if CocoaPods is installed
- Guide you through installation if needed
- Run `pod install` automatically

## Troubleshooting

### "pod: command not found" after installation

If `pod` command still isn't found after installing:

1. **Check if it's in a different location:**
   ```bash
   which pod
   ```

2. **Add to PATH** (if needed):
   ```bash
   export PATH="$PATH:/usr/local/bin"
   ```

3. **Or use full path:**
   ```bash
   /usr/local/bin/pod install
   ```

### "Permission denied" errors

If you get permission errors:

```bash
sudo gem install cocoapods
```

### "Unable to find a specification" errors

Update CocoaPods repo:

```bash
pod repo update
pod install
```

### Still having issues?

1. **Clean and reinstall:**
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter/ios
   rm -rf Pods Podfile.lock
   pod install
   ```

2. **Check Flutter setup:**
   ```bash
   flutter doctor
   ```

## What CocoaPods Does

CocoaPods manages iOS dependencies (like npm for Node.js). Your Flutter app uses native iOS libraries that need to be installed via CocoaPods. The `Podfile` lists these dependencies, and `pod install` downloads and links them.

## Next Steps After Fix

Once `pod install` completes successfully:

1. ✅ Build iOS app with production URL:
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter
   flutter build ios --release --dart-define=API_BASE_URL=https://voxanote-production.up.railway.app
   ```

2. ✅ Test in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. ✅ Archive and deploy to App Store
