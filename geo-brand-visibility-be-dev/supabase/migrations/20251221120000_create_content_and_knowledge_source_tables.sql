-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create SourceType enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'SourceType') THEN
        CREATE TYPE "SourceType" AS ENUM ('FILE', 'URL', 'NOTE');
    END IF;
END$$;

-- Create EmbeddingStatus enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'EmbeddingStatus') THEN
        CREATE TYPE "EmbeddingStatus" AS ENUM ('PENDING', 'INDEXED', 'FAILED');
    END IF;
END$$;

-- Create CompletionStatus enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'CompletionStatus') THEN
        CREATE TYPE "CompletionStatus" AS ENUM ('DRAFTING', 'COMPLETE');
    END IF;
END$$;

-- Create InsightGroup enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'InsightGroup') THEN
        CREATE TYPE "InsightGroup" AS ENUM ('INTENT', 'TOPIC_COVERAGE', 'GUIDANCE');
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ContentFormat') THEN
      CREATE TYPE "ContentFormat" AS ENUM ('MARKDOWN', 'PLAIN_TEXT');
    END IF;
END
$$;


-- Create ContentProfile table
CREATE TABLE IF NOT EXISTS "ContentProfile" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "voiceAndTone" TEXT NOT NULL,
  "audience" TEXT NOT NULL
);

-- Create KnowledgeSource table
CREATE TABLE IF NOT EXISTS "KnowledgeSource" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "sourceType" "SourceType" NOT NULL,
  "storagePath" TEXT NOT NULL,
  "embeddingStatus" "EmbeddingStatus" NOT NULL DEFAULT 'PENDING',
  "vectorStoreId" TEXT NOT NULL
);

-- Create Content table
CREATE TABLE IF NOT EXISTS "Content" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "profileId" UUID NOT NULL REFERENCES "ContentProfile"("id") ON DELETE CASCADE,
  "topicId" UUID NOT NULL REFERENCES "Topic"("id") ON DELETE CASCADE,
  "promptId" UUID REFERENCES "Prompt"("id") ON DELETE CASCADE,
  "body" TEXT NOT NULL,
  "contentFormat" "ContentFormat" NOT NULL DEFAULT 'MARKDOWN',
  "targetKeywords" JSONB NOT NULL,
  "retrievedPages" JSONB NOT NULL,
  "completionStatus" "CompletionStatus" NOT NULL DEFAULT 'DRAFTING',
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create ContentInsight table
CREATE TABLE IF NOT EXISTS "ContentInsight" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "contentId" UUID NOT NULL REFERENCES "Content"("id") ON DELETE CASCADE,
  "insightGroup" "InsightGroup" NOT NULL,
  "type" TEXT NOT NULL,
  "content" TEXT NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Content_KnowledgeSource junction table (many-to-many)
CREATE TABLE IF NOT EXISTS "Content_KnowledgeSource" (
  "contentId" UUID NOT NULL REFERENCES "Content"("id") ON DELETE CASCADE,
  "sourceId" UUID NOT NULL REFERENCES "KnowledgeSource"("id") ON DELETE CASCADE,
  "addedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("contentId", "sourceId")
);