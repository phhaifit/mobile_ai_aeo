CREATE OR REPLACE FUNCTION insert_response(
    "promptId" UUID,
    "modelId" UUID,
    "response" TEXT,
    "position" INTEGER,
    "sentiment" "Sentiment",
    "isCited" BOOLEAN,
    "relatedQuestions" TEXT[],
    "citations" JSONB,
    "competitors" JSONB
)
RETURNS UUID AS $$
DECLARE
    response_id UUID;
BEGIN
    INSERT INTO "Response" (
        "promptId",
        "modelId",
        "response",
        "position",
        "sentiment",
        "isCited",
        "relatedQuestions"
    )
    VALUES (
        "promptId",
        "modelId",
        "response",
        "position",
        "sentiment",
        "isCited",
        COALESCE("relatedQuestions", '{}')
    )
    RETURNING "id" INTO response_id;

    IF "citations" IS NOT NULL THEN
        INSERT INTO "Citation" ("responseId", "url", "domain", "title")
        SELECT
            response_id,
            citation->>'url',
            citation->>'domain',
            citation->>'title'
        FROM jsonb_array_elements("citations") AS citation;
    END IF;

    IF "competitors" IS NOT NULL THEN
        INSERT INTO "CompetitorAnalysisResult" (
            "responseId",
            "competitorId",
            "position",
            "sentiment"
        )
        SELECT
            response_id,
            (competitor->>'id')::UUID,
            (competitor->>'position')::INTEGER,
            (competitor->>'sentiment')::"Sentiment"
        FROM jsonb_array_elements("competitors") AS competitor;
    END IF;

RETURN response_id;
END;
$$ LANGUAGE plpgsql;
