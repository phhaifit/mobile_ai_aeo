CREATE OR REPLACE FUNCTION content_count(prompt_row public."Prompt") 
RETURNS bigint AS $$
  SELECT count(*) 
  FROM "Content" 
  WHERE "promptId" = prompt_row.id;
$$ LANGUAGE sql STABLE;