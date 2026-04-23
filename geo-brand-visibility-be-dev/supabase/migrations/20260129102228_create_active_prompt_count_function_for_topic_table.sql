CREATE OR REPLACE FUNCTION active_prompt_count(topic_row public."Topic") 
RETURNS bigint AS $$
  SELECT count(*) 
  FROM "Prompt" 
  WHERE "topicId" = topic_row.id and "status" = 'active';
$$ LANGUAGE sql STABLE;