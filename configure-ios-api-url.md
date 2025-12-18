# Configure API URL for iPhone

When running the app on iPhone from Xcode, you need to set the API_BASE_URL.

## Option 1: Set in Xcode Scheme (Recommended)

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Arguments** tab
4. Under **Arguments Passed On Launch**, click the **+** button
5. Add: `--dart-define=API_BASE_URL=http://192.168.5.89:4000`
6. Click **Close**

Now when you run from Xcode, it will use the correct IP address.

## Option 2: Run from Terminal

Instead of running from Xcode, run from terminal:

```bash
cd /Users/peterwylie/VoxaNote/mobile_flutter
flutter run -d <your-iphone-id> --dart-define=API_BASE_URL=http://192.168.5.89:4000
```

To find your iPhone device ID:
```bash
flutter devices
```

## Option 3: Update Mac IP if it changed

If your Mac's IP address changed, find the new one:

```bash
ipconfig getifaddr en0
```

Then update the URL in Xcode scheme or the terminal command above.

## Important Notes

- Your iPhone and Mac must be on the **same WiFi network**
- The backend server must be running on port 4000
- If you change networks, you'll need to update the IP address

