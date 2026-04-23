DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='Topic' AND column_name='alias'
    ) THEN
        ALTER TABLE "Topic" ADD COLUMN "alias" Text;
    END IF;
END $$;