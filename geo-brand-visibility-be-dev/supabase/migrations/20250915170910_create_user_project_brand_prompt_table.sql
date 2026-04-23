-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create User table
CREATE TABLE IF NOT EXISTS "User" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "fullname" TEXT NOT NULL,
  "email" TEXT NOT NULL UNIQUE,
  "passwordHash" TEXT,
  "googleId" TEXT UNIQUE,
  "avatar" TEXT,
  "isVerified" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create PromptType enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'PromptType') THEN
        CREATE TYPE "PromptType" AS ENUM ('AWARENESS', 'INTEREST', 'PURCHASE', 'LOYALTY');
    END IF;
END$$;

-- Create Project table
CREATE TABLE IF NOT EXISTS "Project" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "createdBy" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "models" TEXT[] NOT NULL DEFAULT '{}',
  "monitoringFrequency" TEXT NOT NULL DEFAULT 'weekly',
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Brand table
CREATE TABLE IF NOT EXISTS "Brand" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL UNIQUE REFERENCES "Project"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "domain" TEXT NOT NULL,
  "targetMarket" TEXT NOT NULL,
  "industry" TEXT NOT NULL,
  "services" TEXT[] NOT NULL DEFAULT '{}',
  "mission" TEXT NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Prompt table
CREATE TABLE IF NOT EXISTS "Prompt" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "content" TEXT NOT NULL,
  "type" "PromptType" NOT NULL,
  "isMonitored" BOOLEAN NOT NULL DEFAULT FALSE,
  "isDeleted" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS "User_email_idx" ON "User"("email");
CREATE INDEX IF NOT EXISTS "Project_createdBy_idx" ON "Project"("createdBy");
CREATE INDEX IF NOT EXISTS "Prompt_projectId_idx" ON "Prompt"("projectId");

-- Create trigger to automatically update updatedAt
CREATE OR REPLACE FUNCTION update_updatedAt_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_user_updatedAt ON "User";
CREATE TRIGGER update_user_updatedAt
  BEFORE UPDATE ON "User"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

DROP TRIGGER IF EXISTS update_project_updatedAt ON "Project";
CREATE TRIGGER update_project_updatedAt
  BEFORE UPDATE ON "Project"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

DROP TRIGGER IF EXISTS update_brand_updatedAt ON "Brand";
CREATE TRIGGER update_brand_updatedAt
  BEFORE UPDATE ON "Brand"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

DROP TRIGGER IF EXISTS update_prompt_updatedAt ON "Prompt";
CREATE TRIGGER update_prompt_updatedAt
  BEFORE UPDATE ON "Prompt"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

GRANT ALL PRIVILEGES ON SCHEMA public TO service_role;
