-- Fix update_brand: replace COALESCE with sentinel-based CASE pattern
-- for nullable fields, so callers can explicitly set columns to NULL.
-- Sentinel '___NO_UPDATE___' means "do not change this field".
-- Empty string '' means "set to NULL".

-- Drop all versions of update_brand function to ensure a clean slate
DO $$
DECLARE
    func_record RECORD;
BEGIN
    FOR func_record IN
        SELECT oid::regprocedure::text as func_signature
        FROM pg_proc
        WHERE proname = 'update_brand'
          AND pronamespace = 'public'::regnamespace
    LOOP
        EXECUTE 'DROP FUNCTION ' || func_record.func_signature;
    END LOOP;
END $$;

-- Recreate update_brand with sentinel pattern for nullable fields
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
    _logo_url TEXT DEFAULT '___NO_UPDATE___',
    _default_article_image_url TEXT DEFAULT '___NO_UPDATE___',
    _domain_config_method TEXT DEFAULT '___NO_UPDATE___',
    _cloudflare_hostname_id TEXT DEFAULT '___NO_UPDATE___',
    _blog_title TEXT DEFAULT '___NO_UPDATE___',
    _blog_hotline TEXT DEFAULT '___NO_UPDATE___'
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
        "customDomain" = CASE WHEN _custom_domain = '___NO_UPDATE___' THEN "customDomain" WHEN _custom_domain = '' THEN NULL ELSE _custom_domain END,
        "logoUrl" = CASE WHEN _logo_url = '___NO_UPDATE___' THEN "logoUrl" WHEN _logo_url = '' THEN NULL ELSE _logo_url END,
        "defaultArticleImageUrl" = CASE WHEN _default_article_image_url = '___NO_UPDATE___' THEN "defaultArticleImageUrl" WHEN _default_article_image_url = '' THEN NULL ELSE _default_article_image_url END,
        "domainConfigMethod" = CASE WHEN _domain_config_method = '___NO_UPDATE___' THEN "domainConfigMethod" WHEN _domain_config_method = '' THEN NULL ELSE _domain_config_method END,
        "cloudflareHostnameId" = CASE WHEN _cloudflare_hostname_id = '___NO_UPDATE___' THEN "cloudflareHostnameId" WHEN _cloudflare_hostname_id = '' THEN NULL ELSE _cloudflare_hostname_id END,
        "blogTitle" = CASE WHEN _blog_title = '___NO_UPDATE___' THEN "blogTitle" WHEN _blog_title = '' THEN NULL ELSE _blog_title END,
        "blogHotline" = CASE WHEN _blog_hotline = '___NO_UPDATE___' THEN "blogHotline" WHEN _blog_hotline = '' THEN NULL ELSE _blog_hotline END,
        "updatedAt" = NOW()
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
        'slug', updatedBrand."slug",
        'domain', updatedBrand."domain",
        'description', updatedBrand."description",
        'mission', updatedBrand."mission",
        'targetMarket', updatedBrand."targetMarket",
        'industry', updatedBrand."industry",
        'customDomain', updatedBrand."customDomain",
        'logoUrl', updatedBrand."logoUrl",
        'defaultArticleImageUrl', updatedBrand."defaultArticleImageUrl",
        'domainConfigMethod', updatedBrand."domainConfigMethod",
        'cloudflareHostnameId', updatedBrand."cloudflareHostnameId",
        'blogTitle', updatedBrand."blogTitle",
        'blogHotline', updatedBrand."blogHotline",
        'createdAt', updatedBrand."createdAt",
        'updatedAt', updatedBrand."updatedAt",
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
