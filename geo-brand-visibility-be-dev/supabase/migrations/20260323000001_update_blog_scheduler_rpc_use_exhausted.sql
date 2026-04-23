-- Replace retrievedPages-based exclusion with isExhausted flag

DROP FUNCTION IF EXISTS get_prompts_for_blog_scheduler(UUID, INT, INT);

CREATE OR REPLACE FUNCTION get_prompts_for_blog_scheduler(
  p_project_id UUID,
  p_max_tasks INT DEFAULT 100
)
RETURNS TABLE(
  "promptId" UUID,
  "referenceUrl" TEXT,
  "contentProfileId" UUID,
  "contentAgentId" UUID,
  "userId" UUID
) AS $$
DECLARE
  v_agent RECORD;
  v_count INT := 0;
BEGIN
  -- Find active blog agent for this project
  SELECT ca.id, ca."contentProfileId", p."createdBy"
  INTO v_agent
  FROM "ContentAgent" ca
  INNER JOIN "Project" p ON p.id = ca."projectId"
  WHERE ca."projectId" = p_project_id
    AND ca."agentType" = 'BLOG_GENERATOR'
    AND ca."isActive" = true
  LIMIT 1;

  IF v_agent IS NULL THEN
    RETURN;
  END IF;

  -- Phase 1: Agent-configured prompts (priority)
  RETURN QUERY
  SELECT
    apc."promptId",
    apc."referenceUrl",
    v_agent."contentProfileId",
    v_agent.id,
    v_agent."createdBy"
  FROM "AgentPromptConfig" apc
  INNER JOIN "Prompt" pr ON pr.id = apc."promptId"
  INNER JOIN "Topic" tp ON tp.id = pr."topicId"
  WHERE apc."contentAgentId" = v_agent.id
    AND pr.status = 'active'
    AND pr."isDeleted" = false
    AND pr."isExhausted" = false
    AND tp."isDeleted" = false
  LIMIT p_max_tasks;

  GET DIAGNOSTICS v_count = ROW_COUNT;

  -- Phase 2: Supplement with general prompts if needed
  IF v_count < p_max_tasks THEN
    RETURN QUERY
    SELECT
      pr.id,
      NULL::TEXT,
      v_agent."contentProfileId",
      v_agent.id,
      v_agent."createdBy"
    FROM "Prompt" pr
    INNER JOIN "Topic" tp ON tp.id = pr."topicId"
    WHERE tp."projectId" = p_project_id
      AND pr.status = 'active'
      AND pr."isDeleted" = false
      AND pr."isExhausted" = false
      AND tp."isDeleted" = false
      AND NOT EXISTS (
        SELECT 1 FROM "AgentPromptConfig" apc
        WHERE apc."contentAgentId" = v_agent.id AND apc."promptId" = pr.id
      )
    ORDER BY (SELECT count(*) FROM "Content" c WHERE c."promptId" = pr.id) ASC,
             pr."createdAt" ASC
    LIMIT (p_max_tasks - v_count);
  END IF;
END;
$$ LANGUAGE plpgsql;
