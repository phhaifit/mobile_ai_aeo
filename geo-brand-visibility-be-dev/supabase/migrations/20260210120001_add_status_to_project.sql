-- Create ProjectStatus enum type
CREATE TYPE "ProjectStatus" AS ENUM ('DRAFT', 'ACTIVE');

-- Add status column to Project table with default DRAFT
ALTER TABLE "Project" ADD COLUMN "status" "ProjectStatus" NOT NULL DEFAULT 'DRAFT';

-- Update all existing projects to ACTIVE (they already completed setup)
UPDATE "Project" SET "status" = 'ACTIVE';
