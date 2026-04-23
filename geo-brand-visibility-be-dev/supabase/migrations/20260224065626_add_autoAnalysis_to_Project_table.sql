DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'Project'
        AND column_name = 'autoAnalysis'
    ) THEN
        ALTER TABLE "Project"
        ADD COLUMN "autoAnalysis" BOOLEAN DEFAULT FALSE;
    END IF;
END $$;