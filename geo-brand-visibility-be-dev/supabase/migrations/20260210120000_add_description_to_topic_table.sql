-- Add description column to Topic table
ALTER TABLE "Topic"
ADD COLUMN IF NOT EXISTS "description" TEXT;
