-- Drop and recreate update_brand function to remove duplicate
-- This migration consolidates the function definition to include custom domain support

DROP FUNCTION IF EXISTS update_brand(
    UUID,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    TEXT,
    JSONB,
    JSONB
);

-- Recreate the function with custom domain support
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
    _custom_blog_path TEXT DEFAULT '___NO_UPDATE___'
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
        "customBlogPath" = CASE WHEN _custom_blog_path = '___NO_UPDATE___' THEN "customBlogPath" ELSE _custom_blog_path END
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
