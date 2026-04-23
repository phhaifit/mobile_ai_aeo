-- Add price, createdAt, updatedAt fields to Service table
ALTER TABLE "public"."Service"
  ADD COLUMN IF NOT EXISTS "price"     TEXT,
  ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Auto-update updatedAt on every row update
DROP TRIGGER IF EXISTS update_service_updatedAt ON "public"."Service";
CREATE TRIGGER update_service_updatedAt
  BEFORE UPDATE ON "public"."Service"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

-- Create ServiceCategory table
CREATE TABLE IF NOT EXISTS "public"."ServiceCategory" (
  "id"        UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "brandId"   UUID NOT NULL,
  "name"      TEXT NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_ServiceCategory_Brand" FOREIGN KEY ("brandId")
    REFERENCES "public"."Brand" ("id") ON DELETE CASCADE,
  CONSTRAINT "unique_ServiceCategory_Brand" UNIQUE ("name", "brandId")
);

CREATE INDEX IF NOT EXISTS "idx_ServiceCategory_brandId" ON "public"."ServiceCategory" ("brandId");

DROP TRIGGER IF EXISTS update_serviceCategory_updatedAt ON "public"."ServiceCategory";
CREATE TRIGGER update_serviceCategory_updatedAt
  BEFORE UPDATE ON "public"."ServiceCategory"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

-- Add categoryId FK to Service
ALTER TABLE "public"."Service"
  ADD COLUMN IF NOT EXISTS "categoryId" UUID,
  ADD CONSTRAINT "fk_Service_ServiceCategory" FOREIGN KEY ("categoryId")
    REFERENCES "public"."ServiceCategory" ("id") ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS "idx_Service_categoryId" ON "public"."Service" ("categoryId");
