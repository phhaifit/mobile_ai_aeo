ALTER TABLE "User"
  ADD COLUMN IF NOT EXISTS "hasSeenTour" BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN "User"."hasSeenTour"
  IS 'True once user has completed or skipped the product tour. Prevents auto-start on subsequent logins.';
