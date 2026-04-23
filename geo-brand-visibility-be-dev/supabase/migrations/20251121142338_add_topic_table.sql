-- Create table Topic
CREATE TABLE IF NOT EXISTS "Topic" (
  "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "projectId" UUID NOT NULL REFERENCES "Project"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL,
  "searchVolume" INTEGER,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger to update updatedAt on Topic
DROP TRIGGER IF EXISTS update_topic_updatedAt ON "public"."Topic";
CREATE TRIGGER update_topic_updatedAt
    BEFORE UPDATE ON "public"."Topic"
    FOR EACH ROW
    EXECUTE FUNCTION update_updatedAt_column();

-- Update table Prompt to reference Topic
ALTER TABLE "Prompt"
ADD COLUMN IF NOT EXISTS "topicId" UUID NOT NULL REFERENCES "Topic"("id") ON DELETE CASCADE;

INSERT INTO "Topic" ("projectId", "name")
SELECT DISTINCT "projectId", 'Default value'
FROM "Prompt";

UPDATE "Prompt" p
SET "topicId" = t.id
FROM "Topic" t
WHERE p."projectId" = t."projectId";

ALTER TABLE "Prompt"
DROP COLUMN IF EXISTS "projectId";