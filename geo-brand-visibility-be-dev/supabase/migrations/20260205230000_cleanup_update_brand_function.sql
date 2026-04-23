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

-- Recreate the correct and latest version of update_brand
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
    _custom_domain TEXT DEFAULT NULL,
    _logo_url TEXT DEFAULT NULL,
    _default_article_image_url TEXT DEFAULT NULL,
    _domain_config_method TEXT DEFAULT NULL,
    _cloudflare_hostname_id TEXT DEFAULT NULL,
    _blog_title TEXT DEFAULT NULL,
    _blog_hotline TEXT DEFAULT NULL
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
        "customDomain" = COALESCE(_custom_domain, "customDomain"),
        "logoUrl" = COALESCE(_logo_url, "logoUrl"),
        "defaultArticleImageUrl" = COALESCE(_default_article_image_url, "defaultArticleImageUrl"),
        "domainConfigMethod" = COALESCE(_domain_config_method, "domainConfigMethod"),
        "cloudflareHostnameId" = COALESCE(_cloudflare_hostname_id, "cloudflareHostnameId"),
        "blogTitle" = COALESCE(_blog_title, "blogTitle"),
        "blogHotline" = COALESCE(_blog_hotline, "blogHotline"),
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
