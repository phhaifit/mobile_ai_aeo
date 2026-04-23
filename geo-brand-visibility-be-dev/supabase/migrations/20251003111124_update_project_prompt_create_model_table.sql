-- Add new columns
ALTER TABLE "public"."Project"
  ADD COLUMN IF NOT EXISTS "location" TEXT NOT NULL DEFAULT 'Global',
  ADD COLUMN IF NOT EXISTS "language" TEXT NOT NULL DEFAULT 'en';

-- Drop old column
ALTER TABLE "public"."Project"
  DROP COLUMN IF EXISTS "models";

-- Create enum type (only if not already created)
DO $$ BEGIN
  CREATE TYPE monitoring_frequency AS ENUM ('hourly', 'daily', 'weekly', 'monthly');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Drop existing default before converting type
ALTER TABLE "public"."Project"
  ALTER COLUMN "monitoringFrequency" DROP DEFAULT;

-- Convert column to enum type
ALTER TABLE "public"."Project"
  ALTER COLUMN "monitoringFrequency" TYPE monitoring_frequency
  USING "monitoringFrequency"::monitoring_frequency;

-- Re-add default
ALTER TABLE "public"."Project"
  ALTER COLUMN "monitoringFrequency" SET DEFAULT 'weekly';

-- Create Model table
CREATE TABLE IF NOT EXISTS "Model" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT NOT NULL
);

-- Seed default models
INSERT INTO "Model" ("name", "description") VALUES
  ('ChatGPT', 'OpenAI''s advanced conversational AI model'),
  ('AI Overviews', 'Google''s AI-generated search summaries'),
  ('DeepSeek', 'DeepSeek offers powerful language models optimized for deep comprehension and detailed response generation.'),
  ('Copilot', 'Microsoft''s AI-powered assistant'),
  ('Perplexity', 'AI-powered search and answer engine'),
  ('Claude', 'Anthropic''s helpful AI assistant'),
  ('Gemini', 'Google''s multimodal AI assistant')
ON CONFLICT DO NOTHING;

-- Create model_project junction table
CREATE TABLE IF NOT EXISTS "Project_Model" (
  "modelId" UUID NOT NULL REFERENCES "Model"("id") ON DELETE CASCADE,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  PRIMARY KEY ("modelId", "projectId"),
  "addedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add new columns to Prompt table
ALTER TABLE "Prompt"
  ADD COLUMN IF NOT EXISTS "lastRun" TIMESTAMP WITH TIME ZONE,
  ALTER COLUMN "isMonitored" SET DEFAULT TRUE;

-- Update PromptType enum to include new value
ALTER TYPE "PromptType" ADD VALUE IF NOT EXISTS 'CONSIDERATION';