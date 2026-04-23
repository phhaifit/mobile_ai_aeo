-- Add publishedBody column (nullable TEXT) to Content table
-- publishedBody holds the snapshot of body at the time of publish/republish.
-- Public blog and embeddings read from publishedBody, not body.
ALTER TABLE "Content" ADD COLUMN "publishedBody" TEXT;

-- Backfill: copy body to publishedBody for all currently PUBLISHED content
UPDATE "Content"
SET "publishedBody" = "body"
WHERE "completionStatus" = 'PUBLISHED';

-- Recreate view to include publishedBody
DROP VIEW IF EXISTS latest_articles_by_topic_view;

CREATE VIEW latest_articles_by_topic_view AS
SELECT
  c."id",
  c."profileId",
  c."topicId",
  c."promptId",
  c."body",
  c."publishedBody",
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