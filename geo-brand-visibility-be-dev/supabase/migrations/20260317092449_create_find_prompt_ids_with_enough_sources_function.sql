CREATE OR REPLACE FUNCTION find_prompt_ids_with_enough_sources(
  p_project_id UUID,
  p_min_pages INT
)
RETURNS TABLE(prompt_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT c."promptId"
  FROM "Content" c
  INNER JOIN "Topic" t ON t.id = c."topicId"
  WHERE t."projectId" = p_project_id
    AND c."completionStatus" IN ('COMPLETE', 'PUBLISHED')
    AND c."retrievedPages" IS NOT NULL
    AND jsonb_array_length(c."retrievedPages") >= p_min_pages;
END;
$$ LANGUAGE plpgsql;
