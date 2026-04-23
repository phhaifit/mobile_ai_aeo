-- Add slug column to Content table
ALTER TABLE "Content" ADD COLUMN "slug" TEXT;

-- Create unique index for slug to ensure SEO-friendly unique URLs
-- We make it unique per project/brand technically, but globally unique content slugs are often easier to manage
-- Since Content has topic_id -> project_id, we could constrain by project.
-- For now, a simple unique constraint on the table is safest for strict uniqueness.
CREATE UNIQUE INDEX "Content_slug_idx" ON "Content"("slug");
