-- Add headerHtml, footerHtml, theme columns to Brand table (if not exists)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Brand' AND column_name = 'headerHtml') THEN
        ALTER TABLE "Brand" ADD COLUMN "headerHtml" text DEFAULT '';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Brand' AND column_name = 'footerHtml') THEN
        ALTER TABLE "Brand" ADD COLUMN "footerHtml" text DEFAULT '';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Brand' AND column_name = 'theme') THEN
        ALTER TABLE "Brand" ADD COLUMN "theme" text DEFAULT 'light';
    END IF;
END $$;

-- Update insert_brand function to accept and store headerHtml, footerHtml, theme
DROP FUNCTION IF EXISTS insert_brand;
CREATE OR REPLACE FUNCTION insert_brand(
    "projectId" uuid,
    "name" text,
    "domain" text,
    "description" text,
    "mission" text,
    "targetMarket" text,
    "industry" text,
    "services" jsonb,
    "headerHtml" text DEFAULT '',
    "footerHtml" text DEFAULT '',
    "theme" text DEFAULT 'light'
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
        "slug",
        "headerHtml",
        "footerHtml",
        "theme"
    ) VALUES (
        "projectId",
        "name",
        "domain",
        "description",
        "mission",
        "targetMarket",
        "industry",
        generated_slug,
        "headerHtml",
        "footerHtml",
        "theme"
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
        'domain', insertedBrand."domain",
        'headerHtml', insertedBrand."headerHtml",
        'footerHtml', insertedBrand."footerHtml",
        'theme', insertedBrand."theme",
        'services', insertedServices
    );
END;
$$ LANGUAGE plpgsql;
