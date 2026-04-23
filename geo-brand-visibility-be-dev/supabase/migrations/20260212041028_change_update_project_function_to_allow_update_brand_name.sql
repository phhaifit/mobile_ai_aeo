
DROP FUNCTION IF EXISTS update_project(
    _id UUID,
    _monitoring_frequency monitoring_frequency,
    _location TEXT,
    _language TEXT,
    _models JSONB
);

CREATE OR REPLACE FUNCTION update_project(
    _id UUID,
    _monitoring_frequency monitoring_frequency DEFAULT NULL,
    _location TEXT DEFAULT NULL,
    _language TEXT DEFAULT NULL,
    _project_name TEXT DEFAULT NULL,
    _brand_name TEXT DEFAULT NULL,
    _models JSONB DEFAULT '[]'::jsonb
)
RETURNS JSON AS $$
DECLARE
    updatedProject RECORD;
BEGIN
    PERFORM id FROM "Project" WHERE id = _id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Project with id % not found', _id;
    END IF;

    UPDATE "Project"
    SET
        "monitoringFrequency" = COALESCE(_monitoring_frequency, "monitoringFrequency"),
        "location" = COALESCE(_location, "location"),
        "language" = COALESCE(_language, "language"),
        "name" = COALESCE(_project_name, "name"),
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE id = _id
    RETURNING * INTO updatedProject;

    IF _brand_name IS NOT NULL THEN
        UPDATE "Brand"
        SET
            "name" = _brand_name,
            "updatedAt" = CURRENT_TIMESTAMP
        WHERE "projectId" = _id;
    END IF;

    DELETE FROM "Project_Model"
    WHERE "projectId" = _id AND "modelId" NOT IN (
        SELECT value::uuid
        FROM jsonb_array_elements_text(_models)
    );

    INSERT INTO "Project_Model" ("projectId", "modelId")
    SELECT _id, value::uuid
    FROM jsonb_array_elements_text(_models)
    WHERE NOT EXISTS (
        SELECT 1
        FROM "Project_Model"
        WHERE "projectId" = _id AND "modelId" = value::uuid
    );

    RETURN json_build_object(
        'id', updatedProject.id,
        'createdBy', updatedProject."createdBy",
        'name', updatedProject."name",
        'location', updatedProject."location",
        'language', updatedProject."language",
        'monitoringFrequency', updatedProject."monitoringFrequency",
        'createdAt', updatedProject."createdAt",
        'updatedAt', updatedProject."updatedAt",
        'models', _models,
        'brandName', _brand_name
    );
END
$$ LANGUAGE plpgsql;
