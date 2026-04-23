-- Add BullMQ job ID to SocialPostTarget for O(1) job lookup/cancellation
ALTER TABLE "SocialPostTarget"
  ADD COLUMN IF NOT EXISTS "bullmqJobId" TEXT DEFAULT NULL;

CREATE INDEX IF NOT EXISTS "SocialPostTarget_bullmqJobId_idx"
  ON "SocialPostTarget"("bullmqJobId");

COMMENT ON COLUMN "SocialPostTarget"."bullmqJobId"
  IS 'BullMQ job ID for direct job lookup and cancellation. NULL for legacy records.';
