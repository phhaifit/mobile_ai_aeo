-- Add cooldownReason to SocialAccount for tracking why an account is paused
ALTER TABLE "SocialAccount"
  ADD COLUMN IF NOT EXISTS "cooldownReason" VARCHAR DEFAULT NULL;

COMMENT ON COLUMN "SocialAccount"."cooldownReason" IS 'Reason for cooldown: platform_rate_limit | circuit_breaker | manual';

-- Create audit log table for rate limit rejections
CREATE TABLE IF NOT EXISTS "SocialPostRateLimitLog" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "accountId" UUID NOT NULL REFERENCES "SocialAccount"("id") ON DELETE CASCADE,
  "platform" VARCHAR NOT NULL,
  "attemptedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "errorCode" VARCHAR NOT NULL,
  "requestPayloadHash" VARCHAR,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "idx_rate_limit_log_account_time"
  ON "SocialPostRateLimitLog" ("accountId", "attemptedAt" DESC);

CREATE INDEX IF NOT EXISTS "idx_rate_limit_log_user_time"
  ON "SocialPostRateLimitLog" ("userId", "attemptedAt" DESC);
