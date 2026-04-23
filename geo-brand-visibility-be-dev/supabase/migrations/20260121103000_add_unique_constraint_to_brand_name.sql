-- Add UNIQUE constraint to Brand.name field
-- This ensures brand names are unique across the entire database

-- Step 1: Check for existing duplicate brand names before adding the constraint
DO $$
DECLARE
    duplicate_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT "name", COUNT(*) as count
        FROM "Brand"
        GROUP BY "name"
        HAVING COUNT(*) > 1
    ) duplicates;

    IF duplicate_count > 0 THEN
        RAISE EXCEPTION 'Cannot add UNIQUE constraint: % duplicate brand names found. Please resolve duplicates first.', duplicate_count;
    END IF;
END $$;

-- Step 2: Add the UNIQUE constraint on the name column
ALTER TABLE "Brand" ADD CONSTRAINT "Brand_name_key" UNIQUE ("name");

-- Create an index to improve query performance for name lookups
CREATE INDEX IF NOT EXISTS "Brand_name_idx" ON "Brand"("name");
