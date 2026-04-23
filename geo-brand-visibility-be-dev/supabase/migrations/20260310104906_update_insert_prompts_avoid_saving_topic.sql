-- Update insert_prompts function to avoid saving duplicate topics
-- Uses the provided topicId directly.

CREATE OR REPLACE FUNCTION insert_prompts(
    "projectId" TEXT,
    "data" JSONB
)
RETURNS JSONB AS $$
DECLARE
    topic_block JSONB;
    prompt_block JSONB;
    keyword_text TEXT;
    new_topic_id UUID;
    new_prompt_id UUID;
    found_keyword_id UUID;
BEGIN
    FOR topic_block IN
        SELECT jsonb_array_elements(data)
    LOOP
        -- Use the existing topicId provided by the frontend payload
        new_topic_id := (topic_block->>'topicId')::UUID;

        -- Insert Keywords for the topic if present (will do nothing if they exist due to ON CONFLICT)
        IF topic_block ? 'keywords' THEN
            FOR keyword_text IN
                SELECT jsonb_array_elements_text(topic_block->'keywords')
            LOOP
                INSERT INTO "Keyword" (
                    "topicId",
                    "keyword"
                ) VALUES (
                    new_topic_id,
                    keyword_text
                )
                ON CONFLICT ("topicId", "keyword") DO NOTHING;
            END LOOP;
        END IF;

        -- Insert Prompts
        FOR prompt_block IN
            SELECT jsonb_array_elements(topic_block->'prompts')
        LOOP
            INSERT INTO "Prompt" (
                "topicId",
                "content",
                "type",
                "status"
            )
            VALUES (
                new_topic_id,
                prompt_block->>'content',
                (prompt_block->>'type')::"PromptType",
                'active'
            ) RETURNING id INTO new_prompt_id;
            
            -- Map Prompt to Keywords
            IF prompt_block ? 'keywords' THEN
                FOR keyword_text IN
                    SELECT jsonb_array_elements_text(prompt_block->'keywords')
                LOOP
                    -- Find keyword ID
                    SELECT id INTO found_keyword_id FROM "Keyword" 
                    WHERE "topicId" = new_topic_id AND "keyword" = keyword_text;
                    
                    IF found_keyword_id IS NOT NULL THEN
                        INSERT INTO "Prompt_Keyword" ("promptId", "keywordId")
                        VALUES (new_prompt_id, found_keyword_id)
                        ON CONFLICT ("promptId", "keywordId") DO NOTHING;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    END LOOP;

    RETURN '{"success": true}'::JSONB;
END;
$$ LANGUAGE plpgsql;
