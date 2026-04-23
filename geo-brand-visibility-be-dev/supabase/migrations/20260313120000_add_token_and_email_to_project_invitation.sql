-- Add token and inviteeEmail columns to Project_Invitation
ALTER TABLE "Project_Invitation" ADD COLUMN IF NOT EXISTS "token" UUID DEFAULT gen_random_uuid();
ALTER TABLE "Project_Invitation" ADD COLUMN IF NOT EXISTS "inviteeEmail" TEXT;

-- Unique index on token for fast lookup
CREATE UNIQUE INDEX IF NOT EXISTS "Project_Invitation_token_key" ON "Project_Invitation" ("token");
