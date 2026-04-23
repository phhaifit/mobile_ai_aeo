-- Migration: Update ContentInsight table schema
-- Date: 2026-02-01
-- Description: Update InsightGroup enum, add type constraints, and change content from TEXT to JSONB

-- Step 1: Drop the existing foreign key constraint to allow table modification
ALTER TABLE "ContentInsight" DROP CONSTRAINT IF EXISTS "ContentInsight_contentId_fkey";

-- Step 2: Update the InsightGroup enum to remove 'GUIDANCE'
-- First, create a new enum type
DO $$ BEGIN
  CREATE TYPE "InsightGroupNew" AS ENUM ('INTENT', 'TOPIC_COVERAGE');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Step 3: Update the column to use the new enum (this will only work if no 'GUIDANCE' values exist)
-- If GUIDANCE values exist, they should be removed or converted first
DELETE FROM "ContentInsight" WHERE "insightGroup" = 'GUIDANCE';

-- Step 4: Alter the column to use the new enum type
ALTER TABLE "ContentInsight" 
  ALTER COLUMN "insightGroup" TYPE "InsightGroupNew" 
  USING "insightGroup"::text::"InsightGroupNew";

-- Step 5: Drop the old enum and rename the new one
DROP TYPE IF EXISTS "InsightGroup";
ALTER TYPE "InsightGroupNew" RENAME TO "InsightGroup";

-- Step 6: Add CHECK constraint for type column
ALTER TABLE "ContentInsight" 
  ADD CONSTRAINT "ContentInsight_type_check" 
  CHECK (type IN ('objective', 'user intent', 'question coverage', 'subtopic'));

-- Step 7: Convert content column from TEXT to JSONB
-- First, wrap existing text values in quotes to make them valid JSON strings
ALTER TABLE "ContentInsight" 
  ALTER COLUMN "content" TYPE JSONB 
  USING to_jsonb("content");

-- Step 8: Re-add the foreign key constraint
ALTER TABLE "ContentInsight" 
  ADD CONSTRAINT "ContentInsight_contentId_fkey" 
  FOREIGN KEY ("contentId") 
  REFERENCES "Content"("id") 
  ON DELETE CASCADE;

-- Step 9: Create an index on contentId for better query performance
CREATE INDEX IF NOT EXISTS "idx_ContentInsight_contentId" ON "ContentInsight"("contentId");

-- Step 10: Create an index on insightGroup for better filtering
CREATE INDEX IF NOT EXISTS "idx_ContentInsight_insightGroup" ON "ContentInsight"("insightGroup");

-- Add comment to explain the schema
COMMENT ON COLUMN "ContentInsight"."content" IS 'Content stored as JSONB - can be a string or an array of strings';
COMMENT ON COLUMN "ContentInsight"."insightGroup" IS 'Type of insight group - INTENT or TOPIC_COVERAGE';
COMMENT ON COLUMN "ContentInsight"."type" IS 'Specific type - objective, user intent, question coverage, or subtopic';
