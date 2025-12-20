# Set Production API URL in Xcode

## Quick Fix: Add Environment Variable in Xcode

### Step-by-Step:

1. **Open Xcode:**
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter
   open ios/Runner.xcworkspace
   ```

2. **Set Environment Variable:**
   - In Xcode menu: **Product → Scheme → Edit Scheme...**
   - In the left sidebar, select **"Run"** (under "Debug")
   - Click the **"Arguments"** tab at the top
   - Under **"Environment Variables"**, click the **"+"** button
   - Add:
     - **Name:** `API_BASE_URL`
     - **Value:** `https://voxanote-production.up.railway.app`
   - Click **"Close"**

3. **Clean Build Folder:**
   - **Product → Clean Build Folder** (or `Shift + Cmd + K`)

4. **Build and Run:**
   - Click the **Play button** (▶️) or press `Cmd + R`
   - The app should now connect to your Railway backend!

---

## Alternative: Set in Build Settings (More Permanent)

1. **Select Project:**
   - Click **"Runner"** in the left navigator (blue icon at the top)

2. **Select Target:**
   - Under "TARGETS", select **"Runner"**

3. **Build Settings:**
   - Click **"Build Settings"** tab
   - Make sure **"All"** and **"Combined"** are selected (top of the window)

4. **Add User-Defined Setting:**
   - Click the **"+"** button at the top
   - Select **"Add User-Defined Setting"**
   - Name: `API_BASE_URL`
   - Value: `https://voxanote-production.up.railway.app`

5. **Use in Code (if needed):**
   - This sets it as a build setting, but you'll still need the `--dart-define` flag for Flutter to pick it up

---

## Recommended: Use Scheme Environment Variable (Step 2 above)

This is the easiest and most reliable method for Xcode builds.

---

## Verify It's Working

After rebuilding, the app should:
- ✅ Connect to `https://voxanote-production.up.railway.app`
- ✅ No "Cannot connect to server" error
- ✅ Work without local dev server
