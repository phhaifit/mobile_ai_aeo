-- Add status column to Prompt table
-- Status values: 'active', 'suggested', 'inactive'
-- Keep isDeleted for backward compatibility

ALTER TABLE "Prompt" ADD COLUMN IF NOT EXISTS "status" TEXT;

-- Create index for faster filtering by status
CREATE INDEX IF NOT EXISTS "Prompt_status_idx" ON "Prompt"("status");

-- Add comment to document the field
COMMENT ON COLUMN "Prompt"."status" IS 'Prompt status: active, suggested, or inactive. Used for tab filtering.';
