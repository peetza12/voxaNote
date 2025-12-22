-- Make storage_url nullable to support transcript-only recordings
-- Legacy recordings will keep their storage_url, new transcript-only recordings will have NULL
ALTER TABLE recordings ALTER COLUMN storage_url DROP NOT NULL;

