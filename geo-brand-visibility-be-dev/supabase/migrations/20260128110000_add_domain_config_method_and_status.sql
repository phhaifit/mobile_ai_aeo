-- Add domain configuration method and status columns to Brand table
-- Migration for supporting CNAME/Rewrite configuration methods

-- Add new columns
ALTER TABLE "Brand"
ADD COLUMN IF NOT EXISTS "domainConfigMethod" VARCHAR(20) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS "domainStatus" VARCHAR(20) DEFAULT 'not_configured';

-- Add check constraints
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_domain_config_method'
    ) THEN
        ALTER TABLE "Brand"
        ADD CONSTRAINT "chk_domain_config_method"
        CHECK ("domainConfigMethod" IS NULL OR "domainConfigMethod" IN ('cname', 'rewrite'));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_domain_status'
    ) THEN
        ALTER TABLE "Brand"
        ADD CONSTRAINT "chk_domain_status"
        CHECK ("domainStatus" IN ('not_configured', 'pending', 'verified', 'error'));
    END IF;
END $$;

-- Drop and recreate update_brand function with new parameters
DROP FUNCTION IF EXISTS update_brand(
    UUID,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    JSONB,
    JSONB,
    TEXT,
    TEXT
);

CREATE OR REPLACE FUNCTION update_brand(
    _id UUID,
    _name TEXT DEFAULT NULL,
    _domain TEXT DEFAULT NULL,
    _description TEXT DEFAULT NULL,
    _target_market TEXT DEFAULT NULL,
    _industry TEXT DEFAULT NULL,
    _mission TEXT DEFAULT NULL,
    _services_to_update JSONB DEFAULT '[]'::jsonb,
    _services_to_insert JSONB DEFAULT '[]'::jsonb,
    _custom_domain TEXT DEFAULT '___NO_UPDATE___',
    _custom_blog_path TEXT DEFAULT '___NO_UPDATE___',
    _domain_config_method TEXT DEFAULT '___NO_UPDATE___'
)
RETURNS JSON AS $$
DECLARE
    updatedBrand RECORD;
BEGIN
    SELECT * INTO updatedBrand FROM "Brand" WHERE id = _id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Brand with id % not found', _id;
    END IF;

    UPDATE "Brand"
    SET
        "name" = COALESCE(_name, "name"),
        "domain" = COALESCE(_domain, "domain"),
        "description" = COALESCE(_description, "description"),
        "targetMarket" = COALESCE(_target_market, "targetMarket"),
        "industry" = COALESCE(_industry, "industry"),
        "mission" = COALESCE(_mission, "mission"),
        "customDomain" = CASE WHEN _custom_domain = '___NO_UPDATE___' THEN "customDomain" ELSE _custom_domain END,
        "customBlogPath" = CASE WHEN _custom_blog_path = '___NO_UPDATE___' THEN "customBlogPath" ELSE _custom_blog_path END,
        "domainConfigMethod" = CASE WHEN _domain_config_method = '___NO_UPDATE___' THEN "domainConfigMethod" ELSE _domain_config_method END,
        -- Auto-set status to 'pending' when domain is configured
        "domainStatus" = CASE 
            WHEN _custom_domain IS NOT NULL AND _custom_domain != '___NO_UPDATE___' AND _custom_domain != '' THEN 'pending'
            WHEN _custom_domain = '' OR _custom_domain IS NULL THEN 'not_configured'
            ELSE "domainStatus"
        END
    WHERE id = _id
    RETURNING * INTO updatedBrand;

    DELETE FROM "Service"
    WHERE "brandId" = _id AND id NOT IN (
        SELECT (s->>'id')::uuid
        FROM jsonb_array_elements(_services_to_update) AS s
    );

    IF jsonb_array_length(_services_to_update) > 0 THEN
        UPDATE "Service" s
        SET
            "name" = COALESCE(u.name, s.name),
            "description" = COALESCE(u.description, s.description)
        FROM jsonb_to_recordset(_services_to_update) AS u("id" UUID, "name" TEXT, "description" TEXT)
        WHERE s.id = u.id AND s."brandId" = _id;
    END IF;

    IF jsonb_array_length(_services_to_insert) > 0 THEN
        INSERT INTO "Service" ("name", "description", "brandId")
        SELECT
            s.name,
            s.description,
            _id
        FROM jsonb_to_recordset(_services_to_insert) AS s(name TEXT, description TEXT);
    END IF;

    RETURN json_build_object(
        'id', updatedBrand.id,
        'projectId', updatedBrand."projectId",
        'name', updatedBrand."name",
        'domain', updatedBrand."domain",
        'description', updatedBrand."description",
        'mission', updatedBrand."mission",
        'targetMarket', updatedBrand."targetMarket",
        'industry', updatedBrand."industry",
        'customDomain', updatedBrand."customDomain",
        'customBlogPath', updatedBrand."customBlogPath",
        'domainConfigMethod', updatedBrand."domainConfigMethod",
        'domainStatus', updatedBrand."domainStatus",
        'services', (
            SELECT json_agg(
                json_build_object(
                    'id', s.id,
                    'name', s.name,
                    'description', s.description
                )
            )
            FROM "Service" s
            WHERE s."brandId" = _id
        )
    );
END
$$ LANGUAGE plpgsql;
