-- Add safe publishing tracking columns to SocialAccount
ALTER TABLE "SocialAccount"
  ADD COLUMN IF NOT EXISTS "lastPublishedAt" TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS "consecutiveErrorCount" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS "pausedUntil" TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Index for cron job: find queued targets efficiently (FIFO order)
CREATE INDEX IF NOT EXISTS "SocialPostTarget_status_createdAt_idx"
  ON "SocialPostTarget"("status", "createdAt")
  WHERE "status" = 'QUEUED';

-- Index for counting published posts per account in last 24h
CREATE INDEX IF NOT EXISTS "SocialPostTarget_accountId_publishedAt_idx"
  ON "SocialPostTarget"("socialAccountId", "publishedAt")
  WHERE "status" = 'PUBLISHED';
