-- Add avatarUrl and defaultArticleImageUrl columns if not exists
ALTER TABLE "Brand"
  ADD COLUMN IF NOT EXISTS "avatarUrl" TEXT,
  ADD COLUMN IF NOT EXISTS "defaultArticleImageUrl" TEXT;

-- Migrate existing logoUrl data to both new fields (only if columns are empty)
UPDATE "Brand"
SET 
  "avatarUrl" = COALESCE("avatarUrl", "logoUrl"),
  "defaultArticleImageUrl" = COALESCE("defaultArticleImageUrl", "logoUrl")
WHERE "logoUrl" IS NOT NULL;

-- Function to update brand avatar
CREATE OR REPLACE FUNCTION update_brand_avatar(
    _brand_id UUID,
    _avatar_url TEXT
)
RETURNS JSON AS $$
DECLARE
    updated_brand RECORD;
BEGIN
    UPDATE "Brand"
    SET "avatarUrl" = _avatar_url
    WHERE id = _brand_id
    RETURNING * INTO updated_brand;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Brand with id % not found', _brand_id;
    END IF;

    RETURN json_build_object(
        'id', updated_brand.id,
        'projectId', updated_brand."projectId",
        'name', updated_brand."name",
        'slug', updated_brand."slug",
        'domain', updated_brand."domain",
        'description', updated_brand."description",
        'mission', updated_brand."mission",
        'targetMarket', updated_brand."targetMarket",
        'industry', updated_brand."industry",
        'customDomain', updated_brand."customDomain",
        'domainConfigMethod', updated_brand."domainConfigMethod",
        'cloudflareHostnameId', updated_brand."cloudflareHostnameId",
        'logoUrl', updated_brand."logoUrl",
        'avatarUrl', updated_brand."avatarUrl",
        'defaultArticleImageUrl', updated_brand."defaultArticleImageUrl",
        'createdAt', updated_brand."createdAt",
        'updatedAt', updated_brand."updatedAt",
        'services', (
            SELECT json_agg(
                json_build_object(
                    'id', s.id,
                    'name', s.name,
                    'description', s.description
                )
            )
            FROM "Service" s
            WHERE s."brandId" = _brand_id
        )
    );
END
$$ LANGUAGE plpgsql;

-- Function to update default article image
CREATE OR REPLACE FUNCTION update_brand_default_article_image(
    _brand_id UUID,
    _default_article_image_url TEXT
)
RETURNS JSON AS $$
DECLARE
    updated_brand RECORD;
BEGIN
    UPDATE "Brand"
    SET "defaultArticleImageUrl" = _default_article_image_url
    WHERE id = _brand_id
    RETURNING * INTO updated_brand;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Brand with id % not found', _brand_id;
    END IF;

    RETURN json_build_object(
        'id', updated_brand.id,
        'projectId', updated_brand."projectId",
        'name', updated_brand."name",
        'slug', updated_brand."slug",
        'domain', updated_brand."domain",
        'description', updated_brand."description",
        'mission', updated_brand."mission",
        'targetMarket', updated_brand."targetMarket",
        'industry', updated_brand."industry",
        'customDomain', updated_brand."customDomain",
        'domainConfigMethod', updated_brand."domainConfigMethod",
        'cloudflareHostnameId', updated_brand."cloudflareHostnameId",
        'logoUrl', updated_brand."logoUrl",
        'avatarUrl', updated_brand."avatarUrl",
        'defaultArticleImageUrl', updated_brand."defaultArticleImageUrl",
        'createdAt', updated_brand."createdAt",
        'updatedAt', updated_brand."updatedAt",
        'services', (
            SELECT json_agg(
                json_build_object(
                    'id', s.id,
                    'name', s.name,
                    'description', s.description
                )
            )
            FROM "Service" s
            WHERE s."brandId" = _brand_id
        )
    );
END
$$ LANGUAGE plpgsql;
