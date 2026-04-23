-- Migration: ContentInsight - text type -> InsightType enum
ALTER TABLE "ContentInsight"
  DROP CONSTRAINT IF EXISTS "ContentInsight_type_check";

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'insighttype'
      AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public."InsightType" AS ENUM (
      'OBJECTIVE',
      'USER_INTENT',
      'QUESTION_COVERAGE',
      'SUBTOPIC'
    );
  END IF;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'ContentInsight'
      AND column_name = 'type'
      AND data_type = 'text'
  ) THEN
    ALTER TABLE public."ContentInsight"
    ALTER COLUMN type
    TYPE public."InsightType"
    USING type::public."InsightType";
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ContentInsight_contentId_insightGroup_type_unique'
  ) THEN
    ALTER TABLE public."ContentInsight"
    ADD CONSTRAINT ContentInsight_contentId_insightGroup_type_unique
    UNIQUE ("contentId", "insightGroup", type);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS "idx_ContentInsight_type"
ON public."ContentInsight" USING btree (type);