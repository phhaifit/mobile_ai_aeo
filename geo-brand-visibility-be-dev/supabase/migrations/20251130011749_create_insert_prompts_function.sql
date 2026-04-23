-- Update existing prompt types to new values
UPDATE "Prompt"
SET type = 'Informational'
WHERE type = 'AWARENESS' OR type = 'INTEREST' OR type = 'LOYALTY';

UPDATE "Prompt"
SET type = 'Transactional'
WHERE type = 'PURCHASE';

UPDATE "Prompt"
SET type = 'Commercial'
WHERE type = 'CONSIDERATION';

-- Create insert_prompts function
CREATE OR REPLACE FUNCTION insert_prompts(
    "projectId" TEXT,
    "data" JSONB
)
RETURNS JSONB AS $$
DECLARE
    topic_block JSONB;
    prompt_block JSONB;
    new_topic_id UUID;
    new_prompt_id UUID;
BEGIN
    FOR topic_block IN
        SELECT jsonb_array_elements(data)
    LOOP
        INSERT INTO "Topic" (
            "projectId",
            "name"
        ) VALUES (
            "projectId"::UUID,
            topic_block->>'topic'
        ) RETURNING id INTO new_topic_id;

        FOR prompt_block IN
            SELECT jsonb_array_elements(topic_block->'prompts')
        LOOP
            INSERT INTO "Prompt" (
                "topicId",
                "content",
                "type"
            )
            VALUES (
                new_topic_id,
                prompt_block->>'content',
                (prompt_block->>'type')::"PromptType"
            );
        END LOOP;
    END LOOP;

    RETURN '{"success": true}'::JSONB;
END;
$$ LANGUAGE plpgsql;
