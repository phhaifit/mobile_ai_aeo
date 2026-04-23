-- Drop existing credentials because we cannot map them to a specific project
TRUNCATE TABLE "GoogleOAuthCredential" CASCADE;

-- Drop the unique constraint on userId
ALTER TABLE "GoogleOAuthCredential"
  DROP CONSTRAINT IF EXISTS "GoogleOAuthCredential_userId_key";

-- Add projectId as a unique reference
ALTER TABLE "GoogleOAuthCredential"
  ADD COLUMN "projectId" UUID NOT NULL UNIQUE REFERENCES "Project"("id") ON DELETE CASCADE;

CREATE INDEX idx_google_oauth_credential_project ON "GoogleOAuthCredential"("projectId");
