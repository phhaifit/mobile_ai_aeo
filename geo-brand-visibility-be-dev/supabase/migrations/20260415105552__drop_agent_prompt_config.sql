-- Drop AgentPromptConfig table (indexes cascade automatically)
DROP TABLE IF EXISTS "AgentPromptConfig";

-- Update get_prompts_for_blog_scheduler: remove Phase 1 (AgentPromptConfig priority)
-- and the NOT EXISTS exclusion in Phase 2. Now returns all active non-exhausted prompts.
DROP FUNCTION IF EXISTS get_prompts_for_blog_scheduler(UUID, INT);

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
  ORDER BY (SELECT count(*) FROM "Content" c WHERE c."promptId" = pr.id) ASC,
           pr."createdAt" ASC
  LIMIT p_max_tasks;
END;
$$ LANGUAGE plpgsql;


-- Update get_prompts_for_social_media_scheduler: remove Phase 1 (AgentPromptConfig priority)
-- and the NOT EXISTS exclusion in Phase 2. Now returns all active prompts × missing platforms.
DROP FUNCTION IF EXISTS get_prompts_for_social_media_scheduler(UUID, INT);

CREATE OR REPLACE FUNCTION get_prompts_for_social_media_scheduler(
  p_project_id UUID,
  p_max_tasks INT DEFAULT 100
)
RETURNS TABLE(
  "promptId" UUID,
  "referenceUrl" TEXT,
  "platform" TEXT,
  "contentProfileId" UUID,
  "contentAgentId" UUID,
  "userId" UUID
) AS $$
DECLARE
  v_agent RECORD;
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
  INSERT INTO _all_platforms VALUES ('facebook'), ('zalo'), ('linkedin'), ('threads'), ('instagram');

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
      SELECT 1 FROM _existing_content ec
      WHERE ec."promptId" = pr.id AND ec.platform = ap.name
    )
  ORDER BY (SELECT count(*) FROM "Content" c WHERE c."promptId" = pr.id) ASC,
           pr."createdAt" ASC,
           ap.name ASC
  LIMIT p_max_tasks;
END;
$$ LANGUAGE plpgsql;
