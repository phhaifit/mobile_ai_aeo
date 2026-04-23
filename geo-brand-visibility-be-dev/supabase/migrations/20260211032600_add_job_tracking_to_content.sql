-- Add job tracking fields to Content table for progress persistence

-- Add jobId to track SSE stream connection
ALTER TABLE "Content"
ADD COLUMN IF NOT EXISTS "jobId" TEXT;

-- Add step history as JSON array
-- Current step = last item in array
ALTER TABLE "Content"
ADD COLUMN IF NOT EXISTS "stepHistory" JSONB DEFAULT '[]';

-- Index for fast jobId lookup when reconnecting
CREATE INDEX IF NOT EXISTS "Content_jobId_idx" ON "Content"("jobId");
