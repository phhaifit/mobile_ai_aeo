-- Add isMonitored and isDeleted columns to Topic table
ALTER TABLE "Topic"
ADD COLUMN IF NOT EXISTS "isMonitored" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS "isDeleted" BOOLEAN NOT NULL DEFAULT false;
