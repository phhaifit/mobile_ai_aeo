-- Add title column to SocialPost table
ALTER TABLE "SocialPost" ADD COLUMN IF NOT EXISTS "title" TEXT;
