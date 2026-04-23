-- Create Keyword table
CREATE TABLE IF NOT EXISTS "Keyword" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "topicId" UUID NOT NULL REFERENCES "Topic"("id") ON DELETE CASCADE,
  "keyword" TEXT NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Prompt_Keyword junction table
CREATE TABLE IF NOT EXISTS "Prompt_Keyword" (
  "id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  "promptId" UUID NOT NULL REFERENCES "Prompt"("id") ON DELETE CASCADE,
  "keywordId" UUID NOT NULL REFERENCES "Keyword"("id") ON DELETE CASCADE,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("promptId", "keywordId")
);

-- Create trigger for updatedAt on Keyword
DROP TRIGGER IF EXISTS update_keyword_updatedAt ON "public"."Keyword";
CREATE TRIGGER update_keyword_updatedAt
    BEFORE UPDATE ON "public"."Keyword"
    FOR EACH ROW
    EXECUTE FUNCTION update_updatedAt_column();
