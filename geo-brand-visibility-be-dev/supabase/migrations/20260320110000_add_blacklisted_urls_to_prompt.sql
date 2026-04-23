-- BlacklistedUrl table: stores URLs validated as irrelevant for a prompt's content generation
-- Unique constraint on (promptId, url) prevents duplicates and handles concurrent inserts safely
CREATE TABLE IF NOT EXISTS "BlacklistedUrl" (
  "id" UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "promptId" UUID NOT NULL REFERENCES "Prompt"("id") ON DELETE CASCADE,
  "url" TEXT NOT NULL,
  "reason" TEXT,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE ("promptId", "url")
);

CREATE INDEX IF NOT EXISTS idx_blacklisted_url_prompt_id ON "BlacklistedUrl" ("promptId");
