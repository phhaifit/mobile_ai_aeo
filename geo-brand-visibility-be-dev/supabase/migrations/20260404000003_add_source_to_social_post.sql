-- Add source field to SocialPost to distinguish manual vs auto-publish posts
ALTER TABLE "SocialPost"
  ADD COLUMN IF NOT EXISTS "source" VARCHAR NOT NULL DEFAULT 'manual';
