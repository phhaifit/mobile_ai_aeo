ALTER TABLE "Project"
  ADD COLUMN IF NOT EXISTS "strategyReviewedAt" TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS "strategyReviewedById" UUID REFERENCES "User"("id") ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS "strategyReviewedByName" TEXT,
  ADD COLUMN IF NOT EXISTS "strategyReviewedTopicCount" INTEGER,
  ADD COLUMN IF NOT EXISTS "strategyReviewedPromptCount" INTEGER,
  ADD COLUMN IF NOT EXISTS "strategyReviewedScore" REAL;
