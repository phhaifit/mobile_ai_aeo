-- Create CustomerPersona table
CREATE TABLE IF NOT EXISTS "CustomerPersona" (
  "id" UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "brandId" UUID NOT NULL REFERENCES "Brand"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "demographics" JSONB,
  "professional" JSONB,
  "goalsAndMotivations" TEXT,
  "painPoints" TEXT,
  "contentPreferences" JSONB,
  "buyingBehavior" JSONB,
  "isPrimary" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS "CustomerPersona_brandId_idx" ON "CustomerPersona"("brandId");

-- Only one primary persona per brand
CREATE UNIQUE INDEX "CustomerPersona_brand_primary_idx" ON "CustomerPersona" ("brandId") WHERE "isPrimary" = TRUE;

-- Auto-update updatedAt trigger
DROP TRIGGER IF EXISTS update_customer_persona_updatedAt ON "CustomerPersona";
CREATE TRIGGER update_customer_persona_updatedAt
  BEFORE UPDATE ON "CustomerPersona"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();
