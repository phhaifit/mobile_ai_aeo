-- Filter latest_articles_by_topic_view to only include blog_post content type
-- This prevents social_media_post and other content types from appearing on public blog
DROP VIEW IF EXISTS latest_articles_by_topic_view;

CREATE VIEW latest_articles_by_topic_view AS
SELECT
  c."id",
  c."profileId",
  c."topicId",
  c."promptId",
  c."body",
  c."contentFormat",
  c."targetKeywords",
  c."retrievedPages",
  c."completionStatus",
  c."createdAt",
  c."title",
  c."slug",
  c."publishedAt",
  c."jobId",
  c."stepHistory",
  c."contentType",
  c."platform",
  c."thumbnailKey",
  t."name" as "topicName",
  t."alias" as "topicAlias",
  t."projectId" as "projectId",
  ROW_NUMBER() OVER (
    PARTITION BY c."topicId"
    ORDER BY c."createdAt" DESC
  ) as "articleRank"
FROM "Content" c
JOIN "Topic" t ON c."topicId" = t."id"
WHERE c."completionStatus" = 'PUBLISHED'
  AND (c."contentType" = 'blog_post' OR c."contentType" IS NULL);
