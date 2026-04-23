-- Add partial unique index to prevent multiple DRAFT projects per user
-- This enforces at DB level that each user can have only one DRAFT project
CREATE UNIQUE INDEX "Project_createdBy_status_draft_unique" 
ON "Project"("createdBy", "status") 
WHERE "status" = 'DRAFT';

-- Add index on status column for better query performance
-- This improves performance for queries filtering by status
CREATE INDEX "Project_status_idx" ON "Project"("status");
