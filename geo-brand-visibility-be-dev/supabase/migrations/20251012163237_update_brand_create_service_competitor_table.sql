CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Service table for storing services of a Brand
CREATE TABLE IF NOT EXISTS "public"."Service" (
    "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    "name" TEXT NOT NULL,
    "brandId" UUID NOT NULL,
    "description" TEXT,
    CONSTRAINT "fk_Service_Brand" FOREIGN KEY ("brandId")
        REFERENCES "public"."Brand" ("id")
        ON DELETE CASCADE
);

-- Ensure unique name per brand
ALTER TABLE "public"."Service"
ADD CONSTRAINT "unique_Service_Brand" UNIQUE ("name", "brandId");

-- Transfer data from old column (if it exists and contains TEXT[])
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'Brand'
          AND column_name = 'services'
    ) THEN
        INSERT INTO "public"."Service" ("name", "brandId")
        SELECT unnest(services), id
        FROM "public"."Brand"
        WHERE services IS NOT NULL;
    END IF;
END $$;

-- Drop old column
ALTER TABLE "public"."Brand"
DROP COLUMN IF EXISTS services;

-- Create Competitor table for storing competitors of a Brand
CREATE TABLE IF NOT EXISTS "public"."Competitor" (
    "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    "name" TEXT NOT NULL,
    "brandId" UUID NOT NULL,
    "description" TEXT,
    "isSelected" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "fk_Competitor_Brand" FOREIGN KEY ("brandId")
        REFERENCES "public"."Brand" ("id")
        ON DELETE CASCADE
);

-- Ensure unique name per brand
ALTER TABLE "public"."Competitor"
ADD CONSTRAINT "unique_Competitor_Brand" UNIQUE ("name", "brandId");

-- Create indexes
CREATE INDEX IF NOT EXISTS "idx_Service_brandId" ON "public"."Service" ("brandId");
CREATE INDEX IF NOT EXISTS "idx_Competitor_brandId" ON "public"."Competitor" ("brandId");

-- Create trigger to automatically update updatedAt
CREATE OR REPLACE FUNCTION update_updatedAt_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_competitor_updatedAt ON "public"."Competitor";
CREATE TRIGGER update_competitor_updatedAt
BEFORE UPDATE ON "public"."Competitor"
FOR EACH ROW
EXECUTE FUNCTION update_updatedAt_column();
