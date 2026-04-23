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
BEGIN
    INSERT INTO "Brand" (
        "projectId",
        "name",
        "domain",
        "description",
        "mission",
        "targetMarket",
        "industry"
    ) VALUES (
        "projectId",
        "name",
        "domain",
        "description",
        "mission",
        "targetMarket",
        "industry"
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
        'services', insertedServices
    );
END;
$$ LANGUAGE plpgsql;