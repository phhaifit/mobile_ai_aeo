-- Remove UNIQUE constraint from Brand.name field
-- This allows multiple brands to have the same name, as uniqueness is now handled by slug

ALTER TABLE "Brand" DROP CONSTRAINT "Brand_name_key";

-- Also drop the index created for this unique constraint if it exists independently
DROP INDEX IF EXISTS "Brand_name_idx";
