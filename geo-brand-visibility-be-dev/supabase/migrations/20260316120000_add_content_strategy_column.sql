-- Create ContentStrategy enum type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'ContentStrategy'
  ) THEN
    CREATE TYPE "ContentStrategy" AS ENUM ('DEFAULT', 'CLUSTER');
  END IF;
END $$;

-- Add contentStrategy column using enum type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'Content'
      AND column_name = 'contentStrategy'
  ) THEN
    ALTER TABLE "Content"
      ADD COLUMN "contentStrategy" "ContentStrategy" NOT NULL DEFAULT 'DEFAULT'::"ContentStrategy";
  END IF;
END $$;