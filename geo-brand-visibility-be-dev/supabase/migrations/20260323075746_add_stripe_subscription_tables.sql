-- Add Stripe customer ID to Project table
ALTER TABLE "Project"
  ADD COLUMN IF NOT EXISTS "stripeCustomerId" TEXT UNIQUE;

-- Create ProjectSubscription table
CREATE TABLE IF NOT EXISTS "ProjectSubscription" (
  "id"                    UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "projectId"             UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE UNIQUE,
  "stripeSubscriptionId"  TEXT NOT NULL UNIQUE,
  "stripeCustomerId"      TEXT NOT NULL,
  "status"                TEXT NOT NULL DEFAULT 'incomplete',
  "priceId"               TEXT NOT NULL,
  "currentPeriodStart"    TIMESTAMPTZ,
  "currentPeriodEnd"      TIMESTAMPTZ,
  "cancelAtPeriodEnd"     BOOLEAN NOT NULL DEFAULT false,
  "canceledAt"            TIMESTAMPTZ,
  "createdAt"             TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"             TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create StripeEvent table for webhook idempotency
CREATE TABLE IF NOT EXISTS "StripeEvent" (
  "id"           TEXT PRIMARY KEY,
  "eventType"    TEXT NOT NULL,
  "data"         JSONB,
  "status"       TEXT NOT NULL DEFAULT 'success',
  "errorMessage" TEXT,
  "processedAt"  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
