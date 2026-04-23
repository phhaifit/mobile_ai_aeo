DROP FUNCTION IF EXISTS get_analytics(UUID, TIMESTAMPTZ, TIMESTAMPTZ, UUID[], "PromptType"[]);

CREATE OR REPLACE FUNCTION get_analytics(
  p_project_id UUID,
  p_start TIMESTAMPTZ,
  p_end TIMESTAMPTZ,
  p_models UUID[] DEFAULT NULL,
  p_prompt_types "PromptType"[] DEFAULT NULL,
  p_granularity TEXT DEFAULT 'day'
)
RETURNS JSON
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_overall_metrics JSON;
  v_daily_analytics JSON;
  v_model_analytics JSON;
  v_result JSON;
BEGIN
  -- Calculate overall metrics with derived ratios
WITH ai_overview AS (
    SELECT id
    FROM "Model"
    WHERE name = 'AI Overviews'
    LIMIT 1
    )
SELECT json_build_object(
               'brandMentions', brand_mentions,
               'brandMentionsRate', CASE
                                        WHEN total_responses > 0 THEN (brand_mentions::NUMERIC / total_responses * 100)
                                        ELSE 0
                   END,
               'linkReferences', link_references,
               'linkReferencesRate', CASE
                                         WHEN total_responses > 0 THEN (link_references::NUMERIC / total_responses * 100)
                                         ELSE 0
                   END,
               'AIOverviewsCount', ai_overviews_count,
               'AIOverviewsRate', CASE
                                      WHEN total_responses > 0 THEN (ai_overviews_count::NUMERIC / total_responses * 100)
                                      ELSE 0
                   END,
               'totalResponses', total_responses,
               'sentimentStats', json_build_object(
                       'positive', positive_count,
                       'neutral', neutral_count,
                       'negative', negative_count
                                 )
       )
INTO v_overall_metrics
FROM (
         SELECT
             COUNT(r.id) AS total_responses,
             COUNT(r.id) FILTER (WHERE r.position IS NOT NULL) AS brand_mentions,
             COUNT(r.id) FILTER (WHERE r."isCited" = true) AS link_references,
             COUNT(r.id) FILTER (
        WHERE r."modelId" = (SELECT id FROM ai_overview)
      ) AS ai_overviews_count,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Positive') AS positive_count,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Neutral') AS neutral_count,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Negative') AS negative_count
         FROM "Response" r
                  INNER JOIN "Prompt" p ON r."promptId" = p.id
                  INNER JOIN "Model" m ON r."modelId" = m.id
                  INNER JOIN "Topic" t ON p."topicId" = t.id
         WHERE
             t."projectId" = p_project_id
           AND p."isDeleted" = false
           AND r."createdAt" >= p_start
           AND r."createdAt" <= p_end
           AND (p_models IS NULL OR r."modelId" = ANY(p_models))
           AND (p_prompt_types IS NULL OR p.type = ANY(p_prompt_types))
     ) AS metrics;

-- Get analytics breakdown grouped by granularity (day or month)
SELECT json_agg(
               json_build_object(
                       'date', period_date,
                       'totalResponses', total_responses,
                       'brandMentions', brand_mentions,
                       'linkReferences', link_references,
                       'positiveCount', positive_count,
                       'neutralCount', neutral_count,
                       'negativeCount', negative_count
               ) ORDER BY period_date ASC
       )
INTO v_daily_analytics
FROM (
         SELECT
             DATE_TRUNC(p_granularity, r."createdAt")::DATE AS period_date,
             COUNT(r.id) AS total_responses,
             COUNT(r.id) FILTER (WHERE r.position IS NOT NULL) AS brand_mentions,
             COUNT(r.id) FILTER (WHERE r."isCited" = true) AS link_references,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Positive') AS positive_count,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Neutral') AS neutral_count,
             COUNT(r.id) FILTER (WHERE r.sentiment = 'Negative') AS negative_count
         FROM "Response" r
                  INNER JOIN "Prompt" p ON r."promptId" = p.id
                  INNER JOIN "Topic" t ON p."topicId" = t.id
         WHERE
             t."projectId" = p_project_id
           AND p."isDeleted" = false
           AND r."createdAt" >= p_start
           AND r."createdAt" <= p_end
           AND (p_models IS NULL OR r."modelId" = ANY(p_models))
           AND (p_prompt_types IS NULL OR p.type = ANY(p_prompt_types))
         GROUP BY DATE_TRUNC(p_granularity, r."createdAt")::DATE
     ) AS period_metrics;

-- Get analytics by model with competitor mentions
WITH base_responses AS (
    SELECT
        r.id,
        r."modelId",
        r.position,
        m.name AS model_name
    FROM "Response" r
             INNER JOIN "Prompt" p ON r."promptId" = p.id
             INNER JOIN "Model" m ON r."modelId" = m.id
             INNER JOIN "Topic" t ON p."topicId" = t.id
    WHERE
        t."projectId" = p_project_id
      AND p."isDeleted" = false
      AND r."createdAt" >= p_start
      AND r."createdAt" <= p_end
      AND (p_models IS NULL OR r."modelId" = ANY(p_models))
      AND (p_prompt_types IS NULL OR p.type = ANY(p_prompt_types))
),
     model_metrics AS (
         SELECT
             br.model_name,
             COUNT(br.id) FILTER (WHERE br.position IS NOT NULL) AS brand_mentions
         FROM base_responses br
         GROUP BY br.model_name
     ),
     competitor_mentions_by_model AS (
         SELECT
             br.model_name,
             c.name AS competitor_name,
             COUNT(car."responseId") AS mention_count
         FROM base_responses br
                  LEFT JOIN "CompetitorAnalysisResult" car ON br.id = car."responseId"
                  LEFT JOIN "Competitor" c ON car."competitorId" = c.id
         WHERE c.name IS NOT NULL
         GROUP BY br.model_name, c.name
     ),
     total_competitor_mentions AS (
         SELECT
             model_name,
             SUM(mention_count) AS total_competitor_mentions_count
         FROM competitor_mentions_by_model
         GROUP BY model_name
     )
SELECT json_agg(
               json_build_object(
                       'modelName', mm.model_name,
                       'totalMentions', mm.brand_mentions + COALESCE(tcm.total_competitor_mentions_count, 0),
                       'brandMentions', mm.brand_mentions,
                       'competitorMentions', COALESCE(
                               (
                                   SELECT json_object_agg(cmm.competitor_name, cmm.mention_count)
                                   FROM competitor_mentions_by_model cmm
                                   WHERE cmm.model_name = mm.model_name
                               ),
                               '{}'::JSON
                                             )
               ) ORDER BY mm.model_name  )
INTO v_model_analytics
FROM model_metrics mm
         LEFT JOIN total_competitor_mentions tcm ON mm.model_name = tcm.model_name;

-- Combine overall metrics, period analytics, and model analytics
v_result := json_build_object(
    'brandMentions', v_overall_metrics->>'brandMentions',
    'brandMentionsRate', (v_overall_metrics->>'brandMentionsRate')::NUMERIC,
    'linkReferences', v_overall_metrics->>'linkReferences',
    'linkReferencesRate', (v_overall_metrics->>'linkReferencesRate')::NUMERIC,
    'AIOverviewsCount', v_overall_metrics->>'AIOverviewsCount',
    'AIOverviewsRate', (v_overall_metrics->>'AIOverviewsRate')::NUMERIC,
    'totalResponses', v_overall_metrics->>'totalResponses',
    'sentimentStats', v_overall_metrics->'sentimentStats',
    'analyticsByDate', COALESCE(v_daily_analytics, '[]'::JSON),
    'analyticsByModel', COALESCE(v_model_analytics, '[]'::JSON)
  );

RETURN v_result;
END;
$$;
