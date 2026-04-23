DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'Sentiment') THEN
        CREATE TYPE "Sentiment" AS ENUM ('Negative', 'Neutral', 'Positive');
END IF;
END$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS "Response" (
    "id" UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    "promptId" UUID NOT NULL REFERENCES "Prompt"("id") ON DELETE CASCADE,
    "modelId" UUID NOT NULL REFERENCES "Model"("id") ON DELETE CASCADE,
    "response" TEXT NOT NULL,
    "position" INTEGER,
    "sentiment" "Sentiment",
    "isCited" BOOLEAN NOT NULL DEFAULT FALSE,
    "relatedQuestions" TEXT[] NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "Citation" (
    "responseId" UUID NOT NULL REFERENCES "Response"("id") ON DELETE CASCADE,
    "url" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "title" TEXT,
    PRIMARY KEY ("responseId", "url")
);

CREATE TABLE IF NOT EXISTS "CompetitorAnalysisResult" (
    "responseId" UUID NOT NULL REFERENCES "Response"("id") ON DELETE CASCADE,
    "competitorId" UUID NOT NULL REFERENCES "Competitor"("id") ON DELETE CASCADE,
    "position" INTEGER NOT NULL,
    "sentiment" "Sentiment" NOT NULL,
    PRIMARY KEY ("responseId", "competitorId")
);
