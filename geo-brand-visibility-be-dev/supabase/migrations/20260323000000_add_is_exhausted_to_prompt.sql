DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'Prompt' AND column_name = 'isExhausted'
  ) THEN
    ALTER TABLE "Prompt" ADD COLUMN "isExhausted" BOOLEAN NOT NULL DEFAULT false;
  END IF;
END
$$;
