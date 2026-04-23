-- Add publishedAt column to track when content was published
ALTER TABLE "Content" ADD COLUMN "publishedAt" TIMESTAMP NULL;

-- Create index for faster queries on published content
CREATE INDEX "Content_publishedAt_idx" ON "Content"("publishedAt");

-- Add comments to document the columns
COMMENT ON COLUMN "Content"."completionStatus" IS 'Valid values: DRAFTING (generating), COMPLETE (ready for review), PUBLISHED (visible on public blog)';
COMMENT ON COLUMN "Content"."publishedAt" IS 'Timestamp when content was published. NULL if never published or unpublished.';
