-- Add slug column to Brand table
-- This enables public blog URLs like /my-brand/blog

-- Add slug column (nullable initially for backfill)
ALTER TABLE "Brand" ADD COLUMN "slug" TEXT;

-- Backfill existing brands: generate slug from name
-- Replace spaces with dashes and lowercase
UPDATE "Brand" SET "slug" = LOWER(REGEXP_REPLACE(REGEXP_REPLACE("name", '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- Handle any collisions by appending id suffix (must be done BEFORE creating unique index)
UPDATE "Brand" b1 
SET "slug" = b1."slug" || '-' || SUBSTRING(b1."id"::text, 1, 8)
WHERE EXISTS (
  SELECT 1 FROM "Brand" b2 
  WHERE b2."slug" = b1."slug" AND b2."id" < b1."id"
);

-- Make slug NOT NULL after backfill
ALTER TABLE "Brand" ALTER COLUMN "slug" SET NOT NULL;

-- Create unique index on slug AFTER backfill and collision handling
CREATE UNIQUE INDEX "Brand_slug_key" ON "Brand"("slug");

-- Create a helper function to generate unique slugs
CREATE OR REPLACE FUNCTION generate_unique_slug(base_name text)
RETURNS text AS $$
DECLARE
  base_slug text;
  final_slug text;
  counter int := 1;
BEGIN
  -- Slugify: lowercase, replace non-alphanumeric with dashes, collapse multiple dashes
  base_slug := LOWER(REGEXP_REPLACE(REGEXP_REPLACE(base_name, '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));
  base_slug := REGEXP_REPLACE(base_slug, '-+', '-', 'g');
  base_slug := TRIM(BOTH '-' FROM base_slug);
  
  final_slug := base_slug;
  
  -- Check for uniqueness and append counter if needed
  WHILE EXISTS (SELECT 1 FROM "Brand" WHERE "slug" = final_slug) LOOP
    counter := counter + 1;
    final_slug := base_slug || '-' || counter;
  END LOOP;
  
  RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Update insert_brand function to include slug
CREATE OR REPLACE FUNCTION insert_brand(
    "projectId" uuid,
    "name" text,
    "domain" text,
    "description" text,
    "mission" text,
    "targetMarket" text,
    "industry" text,
    "services" jsonb
)
RETURNS json AS $$
DECLARE
    insertedBrand record;
    insertedServices jsonb;
    generated_slug text;
BEGIN
    -- Generate unique slug from brand name
    generated_slug := generate_unique_slug("name");

    INSERT INTO "Brand" (
        "projectId",
        "name",
        "domain",
        "description",
        "mission",
        "targetMarket",
        "industry",
        "slug"
    ) VALUES (
        "projectId",
        "name",
        "domain",
        "description",
        "mission",
        "targetMarket",
        "industry",
        generated_slug
    )
    RETURNING * INTO insertedBrand;

    WITH inserted AS (
        INSERT INTO "Service" ("name", "description", "brandId")
        SELECT
            service->>'name',
            service->>'description',
            insertedBrand.id
        FROM jsonb_array_elements(services) AS service
        RETURNING *
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', inserted.id,
            'brandId', inserted."brandId",
            'name', inserted."name",
            'description', inserted."description"
        )
    )
    INTO insertedServices
    FROM inserted;

    RETURN jsonb_build_object(
        'id', insertedBrand.id,
        'projectId', insertedBrand."projectId",
        'name', insertedBrand."name",
        'description', insertedBrand."description",
        'mission', insertedBrand."mission",
        'targetMarket', insertedBrand."targetMarket",
        'industry', insertedBrand."industry",
        'slug', insertedBrand."slug",
        'services', insertedServices
    );
END;
$$ LANGUAGE plpgsql;
