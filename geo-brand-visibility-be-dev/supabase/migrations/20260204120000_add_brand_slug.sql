-- Add slug column to Brand table for URL-safe identifiers
ALTER TABLE "Brand" ADD COLUMN IF NOT EXISTS "slug" TEXT;

-- Enable unaccent extension for transliteration (e.g., Vietnamese diacritics)
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Backfill slug for existing brands (slugify name, enforce dashes for whitespace)
UPDATE "Brand"
SET "slug" = LOWER(
  REGEXP_REPLACE(
    REGEXP_REPLACE(translate(unaccent("name"), 'đĐ', 'dD'), '\\s+', '-', 'g'),
    '[^a-zA-Z0-9-]',
    '',
    'g'
  )
);

-- Collapse multiple dashes and trim
UPDATE "Brand"
SET "slug" = TRIM(BOTH '-' FROM REGEXP_REPLACE("slug", '-+', '-', 'g'));

-- Handle empty slugs (e.g., names with only special characters)
UPDATE "Brand"
SET "slug" = 'brand-' || SUBSTRING("id"::text, 1, 8)
WHERE "slug" IS NULL OR "slug" = '';

-- Handle collisions deterministically using row_number
WITH ranked AS (
  SELECT
    id,
    slug,
    ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM "Brand"
)
UPDATE "Brand" b
SET "slug" = CASE
  WHEN ranked.rn = 1 THEN ranked.slug
  ELSE ranked.slug || '-' || ranked.rn
END
FROM ranked
WHERE b.id = ranked.id;

-- Enforce NOT NULL and unique index for slug
ALTER TABLE "Brand" ALTER COLUMN "slug" SET NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "Brand_slug_key" ON "Brand"("slug");

-- Helper to generate unique slug for new inserts
CREATE OR REPLACE FUNCTION generate_unique_slug(base_name text)
RETURNS text AS $$
DECLARE
  base_slug text;
  final_slug text;
  counter int := 1;
BEGIN
  base_slug := LOWER(
    REGEXP_REPLACE(
      REGEXP_REPLACE(translate(unaccent(base_name), 'đĐ', 'dD'), '\\s+', '-', 'g'),
      '[^a-zA-Z0-9-]',
      '',
      'g'
    )
  );
  base_slug := REGEXP_REPLACE(base_slug, '-+', '-', 'g');
  base_slug := TRIM(BOTH '-' FROM base_slug);
  IF base_slug IS NULL OR base_slug = '' THEN
    base_slug := 'brand-' || SUBSTRING(uuid_generate_v4()::text, 1, 8);
  END IF;

  final_slug := base_slug;

  WHILE EXISTS (SELECT 1 FROM "Brand" WHERE "slug" = final_slug) LOOP
    counter := counter + 1;
    final_slug := base_slug || '-' || counter;
  END LOOP;

  RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Update insert_brand function to include slug generation
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
        'slug', insertedBrand."slug",
        'description', insertedBrand."description",
        'mission', insertedBrand."mission",
        'targetMarket', insertedBrand."targetMarket",
        'industry', insertedBrand."industry",
        'services', insertedServices
    );
END;
$$ LANGUAGE plpgsql;
