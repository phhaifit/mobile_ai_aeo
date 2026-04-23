-- Create AgentType enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'AgentType') THEN
        CREATE TYPE "AgentType" AS ENUM ('SOCIAL_MEDIA_GENERATOR', 'BLOG_GENERATOR');
    END IF;
END$$;

-- Create ContentAgent table
CREATE TABLE IF NOT EXISTS "ContentAgent" (
  "id" UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "agentType" "AgentType" NOT NULL,
  "contentProfileId" UUID REFERENCES "ContentProfile"("id") ON DELETE SET NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT false,
  "lastRunAt" TIMESTAMP WITH TIME ZONE,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  -- Ensure only one agent of each type per project
  UNIQUE("projectId", "agentType")
);

-- Create AgentPromptConfig table
CREATE TABLE IF NOT EXISTS "AgentPromptConfig" (
  "id" UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "contentAgentId" UUID NOT NULL REFERENCES "ContentAgent"("id") ON DELETE CASCADE,
  "promptId" UUID NOT NULL REFERENCES "Prompt"("id") ON DELETE CASCADE,
  "referenceUrl" TEXT,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS "idx_content_agent_project_id" ON "ContentAgent"("projectId");
CREATE INDEX IF NOT EXISTS "idx_agent_prompt_config_agent_id" ON "AgentPromptConfig"("contentAgentId");
CREATE INDEX IF NOT EXISTS "idx_agent_prompt_config_prompt_id" ON "AgentPromptConfig"("promptId");
