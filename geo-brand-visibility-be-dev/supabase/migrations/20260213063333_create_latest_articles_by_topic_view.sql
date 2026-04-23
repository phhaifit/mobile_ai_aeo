CREATE OR REPLACE VIEW latest_articles_by_topic_view AS
SELECT 
  c.*,
  t."name" as "topicName",
  t."alias" as "topicAlias",
  t."projectId" as "projectId",
  ROW_NUMBER() OVER (
    PARTITION BY c."topicId" 
    ORDER BY c."createdAt" DESC
  ) as "articleRank"
FROM "Content" c
JOIN "Topic" t ON c."topicId" = t."id"
WHERE c."completionStatus" = 'PUBLISHED';