## VoxaNote Monorepo

Minimal Otter.ai‑style voice notes app: record audio on mobile, upload to a Node.js backend for transcription and summarisation with OpenAI, then chat with AI about each recording.

### Structure

- **`server`**: Node.js (TypeScript) + Fastify backend, Postgres, S3‑compatible storage, OpenAI integration.
- **`mobile_flutter`**: Flutter app (Android/iOS) using Riverpod, go_router, Dio, record, and just_audio.

---

## Backend (`server`)

### Prerequisites

- Node.js 18+
- Postgres 15+ with `uuid-ossp` and `vector` extensions.
- S3‑compatible storage (e.g. MinIO, Supabase Storage, or AWS S3).
- OpenAI API key.

### Environment variables

Create a `.env` file in `server`:

```bash
PORT=4000
NODE_ENV=development

# Postgres
POSTGRES_URL=postgres://voxa_user:voxa_pass@localhost:5432/voxa_note

# OpenAI
OPENAI_API_KEY=your-openai-api-key

# S3-compatible storage
S3_ENDPOINT=http://localhost:9000
S3_REGION=us-east-1
S3_ACCESS_KEY_ID=your-access-key
S3_SECRET_ACCESS_KEY=your-secret-key
S3_BUCKET=voxa-note-audio

# Recording constraints
MAX_RECORDING_SECONDS=3600
```

### Postgres setup

Create the database and user (example):

```sql
CREATE DATABASE voxa_note;
CREATE USER voxa_user WITH PASSWORD 'voxa_pass';
GRANT ALL PRIVILEGES ON DATABASE voxa_note TO voxa_user;
```

Enable required extensions and run migrations:

```bash
psql "$POSTGRES_URL" -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
psql "$POSTGRES_URL" -c 'CREATE EXTENSION IF NOT EXISTS vector;'
psql "$POSTGRES_URL" -f migrations/001_init.sql
```

### Install and run backend

```bash
cd server
npm install
npm run build
npm start
```

For development with hot reload:

```bash
cd server
npm run dev
```

### Backend API overview

- **POST `/recordings`**: Create a recording row and return `{ recording, uploadUrl }` where `uploadUrl` is a signed S3 PUT URL.
- **POST `/recordings/:id/process`**: Backend fetches audio from storage, calls OpenAI transcription, generates structured summary JSON, indexes transcript chunks in Postgres/pgvector.
- **GET `/recordings`**: List recordings (title, date, duration, summary).
- **GET `/recordings/:id`**: Recording detail with transcript, summary, status, and `storage_url` for playback.
- **POST `/recordings/:id/chat`**: Ask a question about that recording; backend does retrieval over transcript chunks and returns `{ answer, citations[] }`.
- **DELETE `/recordings/:id`**: Delete recording row, messages, transcript chunks; make sure to also delete audio from storage in a real deployment.

### Backend tests

Run Jest tests:

```bash
cd server
npm test
```

---

## Mobile app (`mobile_flutter`)

### Prerequisites

- Flutter SDK 3.3+ (with Dart 3).
- Xcode (for iOS) and Android SDK / Android Studio (for Android).

### Configure API base URL

The app reads the backend base URL from a Dart define at build time. For local development with an emulator:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:4000
```

On a physical device, use your machine’s LAN IP:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.x.x:4000
```

### iOS and Android permissions

Add microphone and network permissions as usual:

- **iOS**: In `ios/Runner/Info.plist` add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>VoxaNote records audio notes.</string>
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

- **Android**: In `android/app/src/main/AndroidManifest.xml` add:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Install and run Flutter app

```bash
cd mobile_flutter
flutter pub get

# Run on iOS simulator
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:4000

# Run on Android emulator
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

### Core flows in the app

- **RecordPage**
  - Big mic button to start recording with `record` package.
  - Pause / resume / stop controls.
  - Shows elapsed duration and approximate file size.
  - On stop, user can tap “Upload & Process” to:
    - Call backend `/recordings` to create a row and get signed upload URL.
    - Upload audio directly to S3 using signed URL.
    - Trigger `/recordings/:id/process` to transcribe, summarise, and index.
    - Refresh local recordings list and navigate to detail screen.

- **RecordingsListPage**
  - Lists recordings with title, created date, duration, and first summary bullet (or transcript snippet).
  - Pull‑to‑refresh.
  - FAB to open `RecordPage`.

- **RecordingDetailPage**
  - Audio playback with scrubber (`just_audio`).
  - Full transcript (once ready).
  - Structured summary: title, bullet summary, action items.
  - Button to open `ChatPage`.

- **ChatPage**
  - Threaded question/answer UI scoped to a single recording.
  - Uses `/recordings/:id/chat` and shows answer plus citations with timestamps and transcript snippets.

- **SettingsPage**
  - Max recording length (seconds).
  - “Upload on Wi‑Fi only” toggle (currently informational; wire into networking policy if desired).

### Flutter tests

Run Flutter tests:

```bash
cd mobile_flutter
flutter test
```

There is a minimal unit test for the chat provider (`chat_provider_test.dart`) that verifies state transitions around a Q&A interaction.

---

## Notes and limitations

- English‑only transcription and summaries.
- Max recording length is configurable via backend `MAX_RECORDING_SECONDS` and app settings.
- Error handling is intentionally simple but surfaces upload/transcription/summary failures with retry via the UI.
- Auth is optional and not wired in the MVP; the data model supports `user_id` for later multi‑user support.


