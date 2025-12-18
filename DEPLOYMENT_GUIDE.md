# VoxaNote Deployment Guide

Complete step-by-step instructions for deploying to Apple App Store and Google Play Store.

---

## 📱 iOS - Apple App Store Deployment

### Prerequisites
- Apple Developer Account ($99/year) - [Sign up here](https://developer.apple.com/programs/)
- Xcode installed (latest version)
- Your app archive (version 0.1.0+1) already created
- **Privacy Policy URL** (required - see below for quick setup)

### ⚠️ IMPORTANT: Privacy Policy URL Required

**You MUST have a privacy policy URL before submitting to the App Store.** Here are quick options:

#### Option 1: Use a Free Privacy Policy Generator (Fastest - 5 minutes)
1. Visit one of these free generators:
   - [PrivacyGen](https://privacygen.github.io/) - Simple and fast
   - [PrivacyDraft](https://privacydraft.com/) - GDPR/CCPA compliant
   - [WebPolicyGenerator](https://gen-tools.github.io/webpolicygenerator/) - Multiple formats
2. Fill out the form (select "Mobile App", "Voice/Audio Data", etc.)
3. Generate the policy
4. Copy the HTML or text
5. Host it somewhere (see hosting options below)

#### Option 2: Use the Template Provided Below
1. Use the privacy policy template in this guide (see "Privacy Policy Template" section)
2. Customize it with your information
3. Host it (see hosting options below)

#### Option 3: Quick Hosting Solutions

**GitHub Pages (Free & Easy):**
1. Create a new GitHub repository (or use an existing one)
2. Create a file called `privacy-policy.html` with your policy
3. Go to repository Settings → Pages
4. Enable GitHub Pages (select main branch, /root folder)
5. Your URL will be: `https://[your-username].github.io/[repo-name]/privacy-policy.html`
6. Use this URL in App Store Connect

**Other Free Hosting Options:**
- **Netlify**: Drag & drop HTML file → Get instant URL
- **Vercel**: Similar to Netlify, very fast
- **GitHub Gist**: Create a gist, use the raw URL
- **Your existing website**: If you have any website, just add `/privacy-policy.html`

**Minimum Requirements:**
- Must be accessible via HTTPS (required by Apple)
- Must be publicly accessible (no login required)
- Should contain basic privacy information about data collection

### Quick Navigation Reference
**Main Tabs (Top Navigation):**
- **My Apps** - List of all your apps
- **App Store** - Manage app listing, metadata, screenshots
- **TestFlight** - Beta testing and build management
- **Users and Access** - Team management

**Left Sidebar (when viewing an app):**
- **App Store** → **iOS App** → **[Version Number]**
- **App Store** → **App Review** - Submit and track review status
- **App Information** - Basic app details
- **Pricing and Availability** - Pricing settings
- **TestFlight** → **iOS Builds** - View uploaded builds

---

### Step 1: Configure App in App Store Connect

1. **Go to App Store Connect**
   - Visit: https://appstoreconnect.apple.com
   - Sign in with your Apple Developer account
   - You'll see the main dashboard

2. **Create New App**
   - Look at the top of the page for a **blue "+" button** (usually in the top-left area, next to "My Apps")
   - Click the **blue "+" button**
   - From the dropdown menu that appears, click **"New App"**
   - A modal dialog will appear with a form
   - Fill in the form:
     ```
     Platform: Select "iOS" from the dropdown
     Name: Type "VoxaNote"
     Primary Language: Select "English (U.S.)" from the dropdown
     Bundle ID: Click the dropdown and select your bundle ID (e.g., com.yourcompany.voxanote)
                If you don't have one, you need to create it first in Certificates, Identifiers & Profiles
     SKU: Type "voxanote-001" (any unique identifier, this is internal only)
     User Access: Select "Full Access" from the dropdown
     ```
   - Click the blue **"Create"** button at the bottom right of the modal

3. **Configure App Information**
   - After creating the app, you'll be taken to the app's main page
   - Look at the **left sidebar** - you'll see sections like:
     - App Store
     - TestFlight
     - App Information
     - Pricing and Availability
     - etc.
   - Click on **"App Information"** in the left sidebar
   - Fill in the form:
     ```
     Category: Click the dropdown and select "Productivity"
     Subcategory: (optional) Leave blank or select one
     Privacy Policy URL: Enter your privacy policy URL (REQUIRED - must be HTTPS)
                        If you don't have one yet, see "Privacy Policy URL Required" section above
     Support URL: Enter your support website URL (can be same as privacy policy URL)
     Marketing URL: (optional) Leave blank or enter a URL
     ```
   - **Important:** The Privacy Policy URL field is required and must be a valid HTTPS URL
   - If you haven't created one yet, go back to the "Privacy Policy URL Required" section at the top of this guide
   - Click the blue **"Save"** button at the top right of the page

4. **Configure Pricing and Availability**
   - In the left sidebar, click **"Pricing and Availability"**
   - Under "Price Schedule", click **"Free"** (or select a price tier if paid)
   - Under "Availability", leave it as **"All countries or regions"** (default)
     - Or click "Edit" to select specific countries
   - Click the blue **"Save"** button at the top right

---

### Step 2: Prepare App Store Listing

1. **Navigate to App Store Tab**
   - In the left sidebar, click on **"App Store"** (this is a main tab, not a submenu)
   - You'll see a page with version information

2. **Select or Create Version**
   - In the left sidebar under "App Store", you should see **"iOS App"** section
   - Under that, click on **"1.0 Prepare for Submission"** (or the version number you're using)
   - If you don't see a version, you may need to create one first

3. **App Preview and Screenshots** (Required)
   - Scroll down to the **"App Preview and Screenshots"** section
   - You need screenshots for:
     - iPhone 6.7" Display (iPhone 14 Pro Max, 15 Pro Max)
     - iPhone 6.5" Display (iPhone 11 Pro Max, XS Max)
     - iPhone 5.5" Display (iPhone 8 Plus)
   - Minimum: 1 screenshot per size
   - Recommended: 3-5 screenshots per size
   - Format: PNG or JPEG, RGB color space
   - Max file size: 500 MB per image

4. **Description** (Copy and paste this):
   - Scroll down to the **"Description"** text area
   ```
   VoxaNote - AI-Powered Voice Notes

   Transform your voice into organized, searchable notes with AI.

   FEATURES:
   • Record voice notes with high-quality audio
   • Automatic transcription powered by AI
   • Smart summaries with key highlights, action items, and topics
   • Chat with AI about your recordings
   • Find information quickly with intelligent search

   Perfect for meetings, lectures, interviews, and personal notes. VoxaNote helps you capture, organize, and understand your voice recordings effortlessly.

   Privacy-focused: Your recordings are processed securely and you maintain full control of your data.
   ```

5. **Subtitle** (30 characters max):
   - Find the **"Subtitle"** field (usually right above or below Description)
   ```
   AI Voice Notes & Transcription
   ```

6. **Keywords** (100 characters max, comma-separated):
   - Find the **"Keywords"** field
   ```
   voice notes, transcription, AI, meeting notes, voice recorder, audio notes, speech to text
   ```

7. **Support URL**: 
   - Find the **"Support URL"** field
   - Enter: [Your support website]

8. **Marketing URL**: (optional)
   - Find the **"Marketing URL"** field
   - Leave blank or enter a URL

9. **Promotional Text** (170 characters max, optional):
   - Find the **"Promotional Text"** field
   ```
   Record, transcribe, and chat with your voice notes. Powered by AI.
   ```

10. **What's New in This Version**:
   - Scroll down to find the **"What's New in This Version"** text area
   ```
   Initial release of VoxaNote - AI-powered voice notes with transcription, summaries, and chat.
   ```

11. **App Icon**: 
    - Scroll to the **"App Icon"** section
    - Click **"Choose File"** or drag and drop
    - Upload a 1024x1024 PNG (no transparency, no rounded corners)

12. **Copyright**: 
    - Find the **"Copyright"** field
    - Enter: `© 2024 [Your Name/Company]`

13. **Age Rating**: 
    - Scroll to the **"Age Rating"** section
    - Click **"Edit"** or **"Manage"** button
    - Complete the questionnaire that appears
    - Typical answers for a voice notes app:
      - Unrestricted Web Access: No
      - Gambling: No
      - Contests: No
      - etc.
    - Click **"Save"** when done

14. **Save All Changes**
    - Scroll to the top of the page
    - Click the blue **"Save"** button at the top right corner

---

### Step 3: Configure Xcode Project

1. **Open Xcode**
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter/ios
   open Runner.xcworkspace
   ```

2. **Select Runner Target** → "Signing & Capabilities"
   - Team: Select your Apple Developer team
   - Bundle Identifier: e.g., `com.yourcompany.voxanote` (must match App Store Connect)
   - Automatically manage signing: ✅ Checked

3. **Update Version and Build**
   - General tab → Version: `0.1.0`
   - Build: `1`

4. **Add Required Capabilities**
   - Click "+ Capability"
   - Add: "Microphone" (if not already added)
   - Add: "Background Modes" → Check "Audio, AirPlay, and Picture in Picture"

---

### Step 4: Create Archive and Upload

1. **Clean Build Folder**
   - In Xcode: Product → Clean Build Folder (Shift+Cmd+K)

2. **Select "Any iOS Device" as target** (not a simulator)

3. **Create Archive**
   - Product → Archive
   - Wait for archive to complete (may take several minutes)

4. **Upload to App Store**
   - In Organizer window (Window → Organizer)
   - Select your archive
   - Click "Distribute App"
   - Choose: "App Store Connect"
   - Click "Next"
   - Choose: "Upload"
   - Click "Next"
   - Distribution options: Use defaults
   - Click "Next"
   - Review and click "Upload"
   - Wait for upload to complete (may take 10-30 minutes)

---

### Step 5: Submit for Review

1. **Go back to App Store Connect**
   - Visit: https://appstoreconnect.apple.com
   - Sign in if needed
   - Click on **"My Apps"** in the top navigation (if not already there)
   - Click on your **"VoxaNote"** app from the list

2. **Wait for Build Processing** (Important!)
   - After uploading from Xcode, your build needs to be processed
   - Go to the **"TestFlight"** tab (click it in the top navigation tabs)
   - In the left sidebar, click **"iOS Builds"**
   - You'll see your uploaded build with status: "Processing" → "Ready to Submit"
   - **Wait until status shows "Ready to Submit"** (can take 10-60 minutes)
   - You can also test the app here before submitting (optional)

3. **Navigate to App Store Version**
   - Click the **"App Store"** tab at the top (main navigation tabs)
   - In the left sidebar, under "App Store", you should see **"iOS App"**
   - Under "iOS App", click on your version (e.g., **"1.0 Prepare for Submission"**)

4. **Select Build**
   - Scroll down to the **"Build"** section (it's usually below the "App Preview and Screenshots" section)
   - You'll see a section that says "Build" with either:
     - A **"+" button** next to it, OR
     - Text that says "Select a build before you submit your app" with a **"+" button**
   - Click the **"+" button** (or click anywhere in the Build section if it's clickable)
   - A modal dialog will appear showing available builds
   - Look for your build - it should show your version number like "0.1.0 (1)" and status "Ready to Submit"
   - Click on the build to select it (it will highlight)
   - Click the **"Done"** or **"Select"** button at the bottom right of the modal
   - The modal will close and you'll see your build selected
   - Click the blue **"Save"** button at the top right of the page (if it's enabled)

5. **Complete Export Compliance**
   - Scroll down to the **"Export Compliance"** section
   - You'll see a question about encryption
   - Click **"No"** (unless you use encryption beyond standard iOS encryption)
   - Click **"Save"** if prompted

6. **Add for Review**
   - Look at the **top right corner** of the page
   - You should see a blue button that says **"Add for Review"**
   - Click the **"Add for Review"** button
   - A prompt will appear asking if you want to add to an existing draft or create new
   - Select **"Create a new submission"** (or add to existing if you have one)
   - Click **"Continue"** or **"Add"**

7. **Submit for Review**
   - After clicking "Add for Review", you may be automatically taken to the App Review section
   - If not, navigate to the **"App Review"** section:
     - In the left sidebar, under "App Store", click **"App Review"**
   - You'll see your draft submission listed (it may say "Ready to Submit" or show as a draft)
   - Click on the draft submission to open it
   - Review all the information shown
   - Scroll down to the bottom of the page
   - Look for the blue **"Submit for Review"** button (usually at the bottom right)
   - Click the blue **"Submit for Review"** button
   - A confirmation dialog may appear - answer any additional questions
   - Click **"Submit"** or **"Confirm"** in the confirmation dialog to finalize

8. **Wait for Review**
   - Your app status will change to **"Waiting for Review"**
   - Typical review time: 24-48 hours
   - You'll receive email notifications about status changes
   - Check the **"App Review"** section in App Store Connect for updates

---

## 🤖 Android - Google Play Store Deployment

### Prerequisites
- Google Play Developer Account ($25 one-time fee) - [Sign up here](https://play.google.com/console/signup)
- Java JDK 17+ installed
- Android Studio (optional, but helpful)

---

### Step 1: Create App Signing Key

1. **Generate Keystore** (if you don't have one):
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter/android
   keytool -genkey -v -keystore voxanote-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias voxanote
   ```
   
   When prompted, enter:
   ```
   Keystore password: [Choose a strong password - SAVE THIS!]
   Re-enter password: [Same password]
   First and last name: [Your name or company]
   Organizational unit: [Your department]
   Organization: [Your company]
   City: [Your city]
   State: [Your state]
   Country code: [US, GB, etc.]
   ```

2. **Create key.properties file**:
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter/android
   cat > key.properties << 'EOF'
   storePassword=[YOUR_KEYSTORE_PASSWORD]
   keyPassword=[YOUR_KEY_PASSWORD]
   keyAlias=voxanote
   storeFile=voxanote-keystore.jks
   EOF
   ```
   Replace `[YOUR_KEYSTORE_PASSWORD]` and `[YOUR_KEY_PASSWORD]` with your actual passwords.

3. **Add key.properties to .gitignore**:
   ```bash
   echo "android/key.properties" >> /Users/peterwylie/VoxaNote/.gitignore
   echo "android/*.jks" >> /Users/peterwylie/VoxaNote/.gitignore
   ```

---

### Step 2: Configure Android Build

1. **Check build.gradle.kts**:
   ```bash
   cat /Users/peterwylie/VoxaNote/mobile_flutter/android/app/build.gradle.kts
   ```

2. **Update build.gradle.kts** (if needed):
   ```kotlin
   // Add at the top of the file
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       namespace = "com.example.voxa_note_mobile"
       
       defaultConfig {
           applicationId = "com.yourcompany.voxanote"  // Change this!
           minSdk = 21
           targetSdk = 34
           versionCode = 1
           versionName = "0.1.0"
       }

       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       
       buildTypes {
           release {
               signingConfig signingConfigs.release
               // ... other release config
           }
       }
   }
   ```

   **Note**: If your file uses Kotlin DSL (`.kts`), the syntax is slightly different. Let me check your actual file format first.

---

### Step 3: Build Release APK/AAB

1. **Build App Bundle** (recommended for Play Store):
   ```bash
   cd /Users/peterwylie/VoxaNote/mobile_flutter
   flutter build appbundle --release
   ```

   Output will be at: `build/app/outputs/bundle/release/app-release.aab`

2. **Or Build APK** (for direct distribution):
   ```bash
   flutter build apk --release
   ```

   Output will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

### Step 4: Create App in Google Play Console

1. **Go to Google Play Console**
   - Visit: https://play.google.com/console
   - Sign in with your Google Play Developer account

2. **Create New App**
   - Click "Create app"
   - Fill in:
     ```
     App name: VoxaNote
     Default language: English (United States)
     App or game: App
     Free or paid: Free (or Paid)
     ```
   - Check "Declarations" checkboxes
   - Click "Create app"

---

### Step 5: Complete Store Listing

1. **Go to "Store presence" → "Main store listing"**

2. **App Name**: `VoxaNote`

3. **Short description** (80 characters max):
   ```
   AI-powered voice notes with transcription, summaries, and chat
   ```

4. **Full description** (Copy and paste):
   ```
   VoxaNote - AI-Powered Voice Notes

   Transform your voice into organized, searchable notes with AI.

   FEATURES:
   • Record voice notes with high-quality audio
   • Automatic transcription powered by AI
   • Smart summaries with key highlights, action items, and topics
   • Chat with AI about your recordings
   • Find information quickly with intelligent search

   Perfect for meetings, lectures, interviews, and personal notes. VoxaNote helps you capture, organize, and understand your voice recordings effortlessly.

   Privacy-focused: Your recordings are processed securely and you maintain full control of your data.
   ```

5. **App Icon**: Upload 512x512 PNG (required)
6. **Feature Graphic**: 1024x500 PNG (required)
7. **Phone Screenshots**: At least 2, max 8 (required)
   - Minimum: 320px width
   - Maximum: 3840px width
   - Aspect ratio: 16:9 or 9:16
8. **Tablet Screenshots**: (optional but recommended)
9. **Category**: Productivity
10. **Tags**: voice notes, transcription, AI, meeting notes
11. **Contact details**: Your email
12. **Privacy Policy URL**: [Required - your privacy policy]

---

### Step 6: Complete App Content

1. **Go to "Policy" → "App content"**

2. **Complete all sections**:
   - Target audience and content
   - Data safety (required)
   - Ads
   - News apps
   - COVID-19 contact tracing and status apps

3. **Data Safety Form** (Important!):
   - Does your app collect data? Yes
   - Data types: Audio files, Personal info (if applicable)
   - Data usage: App functionality
   - Data sharing: No (unless you share data)
   - Security practices: Describe your security measures

---

### Step 7: Upload and Release

1. **Go to "Production" → "Create new release"**

2. **Upload AAB file**:
   - Click "Upload" under "App bundles"
   - Select: `build/app/outputs/bundle/release/app-release.aab`
   - Wait for processing (5-10 minutes)

3. **Release name**: `0.1.0 (1)`

4. **Release notes** (Copy and paste):
   ```
   Initial release of VoxaNote - AI-powered voice notes with transcription, summaries, and chat.
   ```

5. **Review release**:
   - Check all warnings/errors
   - Fix any issues

6. **Save and Review**:
   - Click "Save"
   - Review the release
   - Click "Start rollout to Production"

7. **Wait for Review**:
   - Typical review time: 1-7 days
   - You'll receive email notifications

---

## 📋 Quick Checklist

### iOS Checklist:
- [ ] **Privacy Policy URL created and hosted** (REQUIRED - see guide above)
- [ ] Apple Developer account created
- [ ] App created in App Store Connect
- [ ] Bundle ID configured in Xcode
- [ ] App Store listing completed (screenshots, description)
- [ ] Privacy Policy URL added in App Information section
- [ ] Archive created and uploaded
- [ ] Build selected in App Store Connect
- [ ] Submitted for review

### Android Checklist:
- [ ] Google Play Developer account created
- [ ] Keystore created and secured
- [ ] key.properties configured
- [ ] App created in Play Console
- [ ] Store listing completed (screenshots, description)
- [ ] Data safety form completed
- [ ] AAB built and uploaded
- [ ] Release created and submitted

---

## 🔐 Important Security Notes

1. **Never commit keystore files or key.properties to git**
2. **Backup your keystore file securely** - you'll need it for all future updates
3. **Save all passwords** - you'll need them for updates
4. **For iOS**: Keep your distribution certificate and provisioning profiles safe

---

## 📞 Support

If you encounter issues:
- **iOS**: Check [Apple Developer Forums](https://developer.apple.com/forums/)
- **Android**: Check [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

## 🎉 After Approval

Once approved:
- **iOS**: App will appear in App Store within 24 hours
- **Android**: App will be available immediately after approval

Remember to update your backend API URLs for production before submitting!

---

## 📄 Privacy Policy Template

If you don't have a privacy policy URL yet, here's a basic template you can customize and host:

### Basic Privacy Policy HTML Template

Create a file called `privacy-policy.html` with this content (customize the bracketed sections):

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VoxaNote Privacy Policy</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1 { color: #000; }
        h2 { color: #555; margin-top: 30px; }
        p { margin: 15px 0; }
        .last-updated { color: #666; font-style: italic; }
    </style>
</head>
<body>
    <h1>Privacy Policy for VoxaNote</h1>
    <p class="last-updated">Last Updated: [DATE - e.g., December 2024]</p>

    <h2>1. Introduction</h2>
    <p>
        VoxaNote ("we", "our", or "us") is committed to protecting your privacy. 
        This Privacy Policy explains how we collect, use, and safeguard your information 
        when you use our mobile application.
    </p>

    <h2>2. Information We Collect</h2>
    <p><strong>Audio Recordings:</strong></p>
    <ul>
        <li>We collect audio recordings that you create using the app</li>
        <li>Recordings are stored securely on our servers</li>
        <li>You can delete recordings at any time through the app</li>
    </ul>

    <p><strong>Transcription Data:</strong></p>
    <ul>
        <li>We process your audio recordings to generate transcriptions</li>
        <li>Transcriptions are created using AI services (OpenAI)</li>
        <li>Transcription data is stored along with your recordings</li>
    </ul>

    <p><strong>Account Information:</strong></p>
    <ul>
        <li>If you create an account, we collect basic account information</li>
        <li>We may collect device information for app functionality</li>
    </ul>

    <h2>3. How We Use Your Information</h2>
    <ul>
        <li>To provide transcription and AI-powered features</li>
        <li>To generate summaries and insights from your recordings</li>
        <li>To enable chat functionality about your recordings</li>
        <li>To improve our services</li>
    </ul>

    <h2>4. Data Storage and Security</h2>
    <p>
        Your recordings and data are stored securely using industry-standard encryption. 
        We use secure cloud storage services to protect your information.
    </p>

    <h2>5. Third-Party Services</h2>
    <p>
        We use OpenAI's services for transcription and AI features. 
        Your audio data may be processed by OpenAI in accordance with their privacy policy. 
        We do not share your data with other third parties for marketing purposes.
    </p>

    <h2>6. Your Rights</h2>
    <ul>
        <li>You can access your recordings and data at any time</li>
        <li>You can delete recordings and data through the app</li>
        <li>You can request deletion of your account and all associated data</li>
    </ul>

    <h2>7. Data Retention</h2>
    <p>
        We retain your recordings and data until you delete them or request account deletion. 
        Deleted data is permanently removed from our systems.
    </p>

    <h2>8. Children's Privacy</h2>
    <p>
        Our app is not intended for children under 13. We do not knowingly collect 
        information from children under 13.
    </p>

    <h2>9. Changes to This Policy</h2>
    <p>
        We may update this Privacy Policy from time to time. 
        We will notify you of any changes by updating the "Last Updated" date.
    </p>

    <h2>10. Contact Us</h2>
    <p>
        If you have questions about this Privacy Policy, please contact us at:<br>
        <strong>Email:</strong> [YOUR_EMAIL_ADDRESS]<br>
        <strong>Support URL:</strong> [YOUR_SUPPORT_URL]
    </p>
</body>
</html>
```

### How to Use This Template:

1. **Copy the HTML above** into a text editor
2. **Replace the bracketed sections:**
   - `[DATE]` - Current date
   - `[YOUR_EMAIL_ADDRESS]` - Your contact email
   - `[YOUR_SUPPORT_URL]` - Your support website (or same URL as privacy policy)
3. **Customize the content** to match your actual data practices
4. **Host it** using one of the methods mentioned in the "Privacy Policy URL Required" section above
5. **Use the URL** in App Store Connect

### Quick GitHub Pages Setup:

```bash
# 1. Create a new GitHub repository (or use existing)
# 2. Create privacy-policy.html file with the template above
# 3. Commit and push:
git add privacy-policy.html
git commit -m "Add privacy policy"
git push

# 4. Enable GitHub Pages:
#    - Go to repository Settings → Pages
#    - Select "main" branch, "/ (root)" folder
#    - Click "Save"
#    - Your URL: https://[username].github.io/[repo-name]/privacy-policy.html
```

**Note:** Make sure to customize this template to accurately reflect how your app actually handles data. Apple may review your privacy policy during app review.

