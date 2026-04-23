-- Remove deprecated orgSlug column from Project table
ALTER TABLE "Project" DROP COLUMN IF EXISTS "orgSlug";
