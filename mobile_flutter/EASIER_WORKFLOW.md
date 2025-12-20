# Easier Development Workflow

## The Problem
Having to close Xcode, clean builds, etc. every time is annoying.

## The Solution

Since we've hardcoded the production URL as the default, you have a few easier options:

### Option 1: Use Flutter Hot Restart (Fastest)

If you're already running the app:

1. **In Xcode or Flutter**: Press `R` (capital R) for hot restart
   - This reloads the app with new code changes
   - Much faster than full rebuild
   - Works for most code changes (including API URL changes)

2. **Or use the restart button** in your IDE/debugger

### Option 2: Use the Quick Scripts

I've created helper scripts:

**Quick rebuild (when you need a full clean):**
```bash
cd mobile_flutter
./quick-rebuild.sh
```

**Quick run (if Flutter is in PATH):**
```bash
cd mobile_flutter
./quick-run.sh
```

### Option 3: Just Rebuild in Xcode (No Clean Needed)

Since the code change is simple (just the default URL), you often don't need to clean:

1. **In Xcode**: Just press `Cmd + R` to rebuild
2. Xcode will detect the code change and rebuild automatically
3. No need to close Xcode or clean derived data

### Option 4: Use Flutter Run Directly (Fastest for Testing)

If you have Flutter in your PATH:

```bash
cd mobile_flutter
flutter run
```

This:
- Builds and runs automatically
- Supports hot reload (press `r` for hot reload, `R` for hot restart)
- Much faster than Xcode builds
- No need to close/clean anything

---

## Recommended Workflow

**For quick testing:**
1. Make code changes
2. Press `R` in Xcode (hot restart) or `r` (hot reload)
3. Done!

**For production builds:**
1. Use the build scripts: `./build-ios-release.sh https://voxanote-production.up.railway.app`
2. Or build in Xcode normally

**Only clean when:**
- You get weird build errors
- Dependencies changed
- You modified native code (iOS/Android)

---

## Pro Tip: Flutter Hot Reload vs Hot Restart

- **Hot Reload (`r`)**: Updates UI instantly, keeps app state
- **Hot Restart (`R`)**: Restarts app, resets state, but keeps running
- **Full Rebuild**: Only needed for native changes or when hot reload fails

For API URL changes, **Hot Restart (`R`)** is usually enough!
