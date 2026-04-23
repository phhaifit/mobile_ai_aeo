DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'ContentAgent' 
        AND column_name = 'postsPerDay'
    ) THEN
        ALTER TABLE "ContentAgent"
        ADD COLUMN "postsPerDay" smallint NOT NULL DEFAULT 10
        CONSTRAINT "ContentAgent_postsPerDay_check" CHECK ("postsPerDay" BETWEEN 1 AND 100);
    END IF;
END $$;