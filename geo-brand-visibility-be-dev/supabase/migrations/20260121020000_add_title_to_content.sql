-- Add title column to Content table
-- Title will be extracted from H1 heading or first sentence during content creation
-- Note: Content titles are unique within a brand (enforced at application level)

-- Add title column (nullable - will be populated for new content only)
ALTER TABLE "Content" ADD COLUMN "title" TEXT;

-- Create index for faster title-based queries and slug generation
CREATE INDEX "Content_title_idx" ON "Content"("title");

