import { createRecording } from './recordingService';

jest.mock('../storage', () => ({
  createSignedUploadUrl: jest.fn(async () => ({
    key: 'recordings/anon/test.m4a',
    url: 'https://signed-upload-url',
  })),
  getPublicUrlFromKey: (key: string) => `https://storage/${key}`,
}));

jest.mock('../db', () => ({
  query: jest.fn(async () => ({
    rows: [
      {
        id: 'test-id',
        user_id: null,
        title: 'Test',
        created_at: new Date().toISOString(),
        duration_sec: 10,
        storage_url: 'https://storage/recordings/anon/test.m4a',
        transcript_text: null,
        transcript_json: null,
        summary_json: null,
        status: 'pending',
      },
    ],
  })),
}));

describe('createRecording', () => {
  it('creates a recording and returns upload url', async () => {
    const { recording, uploadUrl } = await createRecording({
      title: 'Test',
      durationSec: 10,
    });

    expect(recording.id).toBe('test-id');
    expect(uploadUrl).toBe('https://signed-upload-url');
    expect(recording.storage_url).toContain('recordings/anon');
  });
});


