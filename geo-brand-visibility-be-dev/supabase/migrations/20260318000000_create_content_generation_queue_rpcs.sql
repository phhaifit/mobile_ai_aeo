-- Drop old RPC that is now consolidated into get_prompts_for_blog_scheduler
DROP FUNCTION IF EXISTS find_prompt_ids_with_enough_sources(UUID, INT);

-- RPC 1: Get blog content generation queue for a project
-- Returns prompts to generate blog content for, prioritizing agent-configured prompts
-- then supplementing with general prompts. Excludes prompts that already have
-- content with enough retrieved pages.
CREATE OR REPLACE FUNCTION get_prompts_for_blog_scheduler(
  p_project_id UUID,
  p_max_tasks INT DEFAULT 100,
  p_min_retrieved_pages INT DEFAULT 10
)
RETURNS TABLE(
  prompt_id UUID,
  reference_url TEXT,
  content_profile_id UUID,
  content_agent_id UUID,
  user_id UUID
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

  -- Collect prompts with enough sources to exclude
  -- (applies to both agent-configured and general prompts)
  CREATE TEMP TABLE _excluded_prompts ON COMMIT DROP AS
  SELECT DISTINCT c."promptId" AS id
  FROM "Content" c
  INNER JOIN "Topic" t ON t.id = c."topicId"
  WHERE t."projectId" = p_project_id
    AND c."completionStatus" IN ('COMPLETE', 'PUBLISHED')
    AND c."retrievedPages" IS NOT NULL
    AND jsonb_array_length(c."retrievedPages") >= p_min_retrieved_pages;

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
    AND tp."isDeleted" = false
    AND NOT EXISTS (SELECT 1 FROM _excluded_prompts ep WHERE ep.id = apc."promptId")
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
      AND tp."isDeleted" = false
      AND NOT EXISTS (SELECT 1 FROM _excluded_prompts ep WHERE ep.id = pr.id)
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


-- RPC 2: Get social media content generation queue for a project
-- Returns (prompt, platform) pairs that are missing social media content.
-- Prioritizes agent-configured prompts, then supplements with general prompts.
CREATE OR REPLACE FUNCTION get_prompts_for_social_media_scheduler(
  p_project_id UUID,
  p_max_tasks INT DEFAULT 100
)
RETURNS TABLE(
  prompt_id UUID,
  reference_url TEXT,
  platform TEXT,
  content_profile_id UUID,
  content_agent_id UUID,
  user_id UUID
) AS $$
DECLARE
  v_agent RECORD;
  v_count INT := 0;
BEGIN
  -- Find active social media agent for this project
  SELECT ca.id, ca."contentProfileId", p."createdBy"
  INTO v_agent
  FROM "ContentAgent" ca
  INNER JOIN "Project" p ON p.id = ca."projectId"
  WHERE ca."projectId" = p_project_id
    AND ca."agentType" = 'SOCIAL_MEDIA_GENERATOR'
    AND ca."isActive" = true
  LIMIT 1;

  IF v_agent IS NULL THEN
    RETURN;
  END IF;

  -- All available platforms
  CREATE TEMP TABLE _all_platforms(name TEXT) ON COMMIT DROP;
  INSERT INTO _all_platforms VALUES ('facebook'), ('zalo'), ('linkedin');

  -- Existing (prompt, platform) pairs that are already complete
  CREATE TEMP TABLE _existing_content ON COMMIT DROP AS
  SELECT DISTINCT c."promptId", c.platform
  FROM "Content" c
  INNER JOIN "Topic" t ON t.id = c."topicId"
  WHERE t."projectId" = p_project_id
    AND c."contentType" = 'social_media_post'
    AND c."completionStatus" IN ('COMPLETE', 'PUBLISHED')
    AND c.body <> ''
    AND c.platform IS NOT NULL;

  -- Phase 1: Agent-configured prompts × missing platforms
  RETURN QUERY
  SELECT
    apc."promptId",
    apc."referenceUrl",
    ap.name,
    v_agent."contentProfileId",
    v_agent.id,
    v_agent."createdBy"
  FROM "AgentPromptConfig" apc
  INNER JOIN "Prompt" pr ON pr.id = apc."promptId"
  INNER JOIN "Topic" tp ON tp.id = pr."topicId"
  CROSS JOIN _all_platforms ap
  WHERE apc."contentAgentId" = v_agent.id
    AND pr.status = 'active'
    AND pr."isDeleted" = false
    AND tp."isDeleted" = false
    AND NOT EXISTS (
      SELECT 1 FROM _existing_content ec
      WHERE ec."promptId" = apc."promptId" AND ec.platform = ap.name
    )
  LIMIT p_max_tasks;

  GET DIAGNOSTICS v_count = ROW_COUNT;

  -- Phase 2: Supplement with general prompts × missing platforms
  IF v_count < p_max_tasks THEN
    RETURN QUERY
    SELECT
      pr.id,
      NULL::TEXT,
      ap.name,
      v_agent."contentProfileId",
      v_agent.id,
      v_agent."createdBy"
    FROM "Prompt" pr
    INNER JOIN "Topic" tp ON tp.id = pr."topicId"
    CROSS JOIN _all_platforms ap
    WHERE tp."projectId" = p_project_id
      AND pr.status = 'active'
      AND pr."isDeleted" = false
      AND tp."isDeleted" = false
      AND NOT EXISTS (
        SELECT 1 FROM "AgentPromptConfig" apc
        WHERE apc."contentAgentId" = v_agent.id AND apc."promptId" = pr.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM _existing_content ec
        WHERE ec."promptId" = pr.id AND ec.platform = ap.name
      )
    ORDER BY (SELECT count(*) FROM "Content" c WHERE c."promptId" = pr.id) ASC,
             pr."createdAt" ASC,
             ap.name ASC
    LIMIT (p_max_tasks - v_count);
  END IF;
END;
$$ LANGUAGE plpgsql;
