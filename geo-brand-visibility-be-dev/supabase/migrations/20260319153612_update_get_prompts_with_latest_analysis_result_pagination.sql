DROP FUNCTION IF EXISTS get_prompts_with_latest_analysis_result_pagination(UUID, UUID, INT, INT);
DROP FUNCTION IF EXISTS get_prompts_with_latest_analysis_result_pagination(UUID, UUID, INT, INT, TEXT, "PromptType", BOOLEAN);
DROP FUNCTION IF EXISTS get_prompts_with_latest_analysis_result_pagination(UUID, UUID, INT, INT, TEXT, "PromptType"[], BOOLEAN);

CREATE OR REPLACE FUNCTION get_prompts_with_latest_analysis_result_pagination(
	p_project_id UUID,
	p_user_id UUID,
    p_limit INT DEFAULT 10,
	p_offset INT DEFAULT 0,
	p_search TEXT DEFAULT NULL,
	p_type "PromptType"[] DEFAULT NULL,
	p_is_monitored BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
	"id" UUID,
	"content" TEXT,
	"type" "PromptType",
	"isMonitored" BOOLEAN,
	"isDeleted" BOOLEAN,
	"createdAt" TIMESTAMP WITH TIME ZONE,
	"updatedAt" TIMESTAMP WITH TIME ZONE,
	"lastRun" TIMESTAMP WITH TIME ZONE,
	"topicId" UUID,
	"status" TEXT,
	"topicName" TEXT,
	"keywords" TEXT[],
	"latestResults" JSONB
) AS $$
	SELECT
		p.*,
		t.name AS "topicName",
		COALESCE((
			SELECT array_agg(k1.keyword)
			FROM "Keyword" k1
			JOIN "Prompt_Keyword" pk1 ON k1.id = pk1."keywordId"
			WHERE pk1."promptId" = p.id
		), ARRAY[]::TEXT[]) AS "keywords",
		COALESCE((
			SELECT jsonb_agg(
				jsonb_build_object(
					'model', res2.model,
					'isMentioned', res2.is_mentioned,
					'isCited', res2."isCited",
					'sentiment', res2.sentiment
				)
			)
			FROM (
				SELECT DISTINCT ON (r2."modelId")
					m2.name AS model,
					(r2.position IS NOT NULL) AS is_mentioned,
					r2."isCited",
					r2.sentiment
				FROM "Response" r2
				JOIN "Model" m2 ON r2."modelId" = m2.id
				WHERE r2."promptId" = p.id
				ORDER BY r2."modelId", r2."createdAt" DESC
			) res2
		), '[]'::JSONB) AS "latestResults"
	FROM "Prompt" p
        JOIN "Topic" t ON p."topicId" = t.id
        JOIN "Project" prj ON t."projectId" = prj.id
        JOIN "Project_Member" mem ON prj.id = mem."projectId"
	WHERE prj.id = p_project_id
		AND mem."userId" = p_user_id
		AND p.status = 'active'
		AND p."isDeleted" = false
		AND (p_search IS NULL OR p_search = '' OR p."content" ILIKE '%' || p_search || '%')
		AND (p_type IS NULL OR array_length(p_type, 1) IS NULL OR p."type" = ANY(p_type))
		AND (p_is_monitored IS NULL OR p."isMonitored" = p_is_monitored)
	ORDER BY p."createdAt" DESC
	LIMIT p_limit
	OFFSET p_offset;
$$ LANGUAGE sql STABLE;
