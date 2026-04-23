-- Add contentType column to Content table
-- Stores which type of content was generated (blog_post, social_media_post, email, copywriting)
ALTER TABLE "Content"
    ADD COLUMN IF NOT EXISTS "contentType" TEXT NOT NULL DEFAULT 'blog_post';

-- Add platform column to Content table
-- Only used for social_media_post content type (facebook, zalo, linkedin)
ALTER TABLE "Content"
    ADD COLUMN IF NOT EXISTS "platform" TEXT;

-- Index for filtering by contentType
CREATE INDEX IF NOT EXISTS "idx_Content_contentType" ON "Content" ("contentType");
