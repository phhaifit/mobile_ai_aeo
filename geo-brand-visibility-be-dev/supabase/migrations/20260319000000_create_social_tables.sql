-- Create SocialAccount table
-- Stores connected social media accounts (pages, bots, webhooks, API credentials)
-- Supports 4 connection types: oauth, token, webhook, credentials
CREATE TABLE IF NOT EXISTS "SocialAccount" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "platform" TEXT NOT NULL,
  "connectionType" TEXT NOT NULL,
  "platformAccountId" TEXT NOT NULL,
  "accountName" TEXT NOT NULL,
  "accountAvatar" TEXT,
  "credentials" JSONB NOT NULL DEFAULT '{}',
  "tokenExpiresAt" TIMESTAMP WITH TIME ZONE,
  "metadata" JSONB DEFAULT '{}',
  "connectedByUserId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "SocialAccount_platform_check" CHECK ("platform" IN ('facebook', 'instagram', 'youtube', 'tiktok', 'x', 'linkedin', 'threads', 'pinterest', 'reddit', 'telegram', 'zalo', 'line', 'discord', 'slack', 'wordpress', 'blogger', 'medium')),
  CONSTRAINT "SocialAccount_connectionType_check" CHECK ("connectionType" IN ('oauth', 'token', 'webhook', 'credentials')),
  CONSTRAINT "SocialAccount_unique_platform_account" UNIQUE ("projectId", "platform", "platformAccountId")
);

-- Create SocialPost table
-- Stores the original content composed by the user
CREATE TABLE IF NOT EXISTS "SocialPost" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "contentId" UUID,
  "message" TEXT NOT NULL,
  "mediaUrls" JSONB DEFAULT '[]',
  "linkUrl" TEXT,
  "metadata" JSONB DEFAULT '{}',
  "createdByUserId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "scheduledAt" TIMESTAMP WITH TIME ZONE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create SocialPostTarget table
-- Each post × each account = 1 target, tracks status independently
CREATE TABLE IF NOT EXISTS "SocialPostTarget" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "socialPostId" UUID NOT NULL REFERENCES "SocialPost"("id") ON DELETE CASCADE,
  "socialAccountId" UUID NOT NULL REFERENCES "SocialAccount"("id") ON DELETE CASCADE,
  "status" TEXT NOT NULL DEFAULT 'PENDING',
  "platformPayload" JSONB DEFAULT '{}',
  "platformPostId" TEXT,
  "platformPostUrl" TEXT,
  "errorMessage" TEXT,
  "errorType" TEXT,
  "publishedAt" TIMESTAMP WITH TIME ZONE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "SocialPostTarget_status_check" CHECK ("status" IN ('PENDING', 'QUEUED', 'PUBLISHING', 'PUBLISHED', 'FAILED')),
  CONSTRAINT "SocialPostTarget_errorType_check" CHECK ("errorType" IS NULL OR "errorType" IN ('RETRYABLE', 'FATAL', 'AUTH_EXPIRED'))
);

-- Create indexes
CREATE INDEX IF NOT EXISTS "SocialAccount_projectId_idx" ON "SocialAccount"("projectId");
CREATE INDEX IF NOT EXISTS "SocialAccount_connectedByUserId_idx" ON "SocialAccount"("connectedByUserId");
CREATE INDEX IF NOT EXISTS "SocialAccount_platform_idx" ON "SocialAccount"("platform");

CREATE INDEX IF NOT EXISTS "SocialPost_projectId_idx" ON "SocialPost"("projectId");
CREATE INDEX IF NOT EXISTS "SocialPost_createdByUserId_idx" ON "SocialPost"("createdByUserId");
CREATE INDEX IF NOT EXISTS "SocialPost_scheduledAt_idx" ON "SocialPost"("scheduledAt");

CREATE INDEX IF NOT EXISTS "SocialPostTarget_socialPostId_idx" ON "SocialPostTarget"("socialPostId");
CREATE INDEX IF NOT EXISTS "SocialPostTarget_socialAccountId_idx" ON "SocialPostTarget"("socialAccountId");
CREATE INDEX IF NOT EXISTS "SocialPostTarget_status_idx" ON "SocialPostTarget"("status");

-- Create updatedAt triggers
DROP TRIGGER IF EXISTS update_social_account_updatedAt ON "SocialAccount";
CREATE TRIGGER update_social_account_updatedAt
  BEFORE UPDATE ON "SocialAccount"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

DROP TRIGGER IF EXISTS update_social_post_updatedAt ON "SocialPost";
CREATE TRIGGER update_social_post_updatedAt
  BEFORE UPDATE ON "SocialPost"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

DROP TRIGGER IF EXISTS update_social_post_target_updatedAt ON "SocialPostTarget";
CREATE TRIGGER update_social_post_target_updatedAt
  BEFORE UPDATE ON "SocialPostTarget"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

-- Grant permissions
GRANT ALL ON "SocialAccount" TO anon, authenticated, service_role;
GRANT ALL ON "SocialPost" TO anon, authenticated, service_role;
GRANT ALL ON "SocialPostTarget" TO anon, authenticated, service_role;
