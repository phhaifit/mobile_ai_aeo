-- Add orgSlug column to Project table for SEO-friendly blog URLs
-- This allows URLs like /acme-corp/blog instead of /uuid-123/blog

-- Add orgSlug column (nullable initially)
ALTER TABLE "Project"
ADD COLUMN IF NOT EXISTS "orgSlug" TEXT;

-- Create unique index on orgSlug for fast lookups
CREATE UNIQUE INDEX IF NOT EXISTS "Project_orgSlug_idx"
ON "Project"("orgSlug");

-- Add comment explaining the column
COMMENT ON COLUMN "Project"."orgSlug"
IS 'SEO-friendly organization slug for public blog URLs (e.g., acme-corp)';
