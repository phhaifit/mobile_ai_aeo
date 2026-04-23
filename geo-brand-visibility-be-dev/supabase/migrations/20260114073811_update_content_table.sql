DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type WHERE typname = 'ContentFormat'
    ) THEN
        CREATE TYPE "ContentFormat" AS ENUM ('MARKDOWN', 'PLAIN_TEXT');
    END IF;
END
$$;

-- Add body column
ALTER TABLE "Content"
ADD COLUMN IF NOT EXISTS "body" TEXT;

-- Add contentFormat column
ALTER TABLE "Content"
ADD COLUMN IF NOT EXISTS "contentFormat" "ContentFormat";

UPDATE "Content"
SET
    "body" = COALESCE("body", ''),
    "contentFormat" = COALESCE("contentFormat", 'MARKDOWN');

ALTER TABLE "Content"
ALTER COLUMN "body" SET NOT NULL;

ALTER TABLE "Content"
ALTER COLUMN "contentFormat" SET NOT NULL;

ALTER TABLE "Content"
ALTER COLUMN "contentFormat" SET DEFAULT 'MARKDOWN';
