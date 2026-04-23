-- Create DefaultContentProfile table (template for seeding per-project profiles)
CREATE TABLE IF NOT EXISTS "DefaultContentProfile" (
  "id" UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  "language" TEXT NOT NULL DEFAULT 'en',
  "name" TEXT NOT NULL,
  "description" TEXT,
  "voiceAndTone" TEXT NOT NULL,
  "audience" TEXT NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create unique constraint on language + name to prevent duplicates
CREATE UNIQUE INDEX IF NOT EXISTS "DefaultContentProfile_language_name_key"
  ON "DefaultContentProfile" ("language", "name");

-- Seed default English writing styles
INSERT INTO "DefaultContentProfile" ("language", "name", "description", "voiceAndTone", "audience")
VALUES
  (
    'en',
    'Professional Authority',
    'A confident, knowledgeable writing style that positions the brand as an industry leader. Uses data-driven insights, clear structure, and authoritative language to build trust and credibility.',
    'Confident, knowledgeable, and trustworthy. Formal but approachable tone with structured, informative language. Uses active voice and strong assertions backed by evidence. Avoids jargon overload while explaining complex concepts clearly.',
    'Business professionals, decision-makers, and C-level executives. Industry peers and potential partners aged 30-55 who value expertise, data, and actionable insights.'
  ),
  (
    'en',
    'Conversational Educator',
    'A friendly, engaging writing style that simplifies complex topics into easy-to-understand content. Combines education with storytelling to keep readers engaged while delivering practical value.',
    'Friendly, relatable, and encouraging. Casual but informative tone that is warm and enthusiastic. Uses analogies, examples, and questions to engage readers. Breaks down complex ideas into digestible pieces.',
    'Small business owners, marketers, and entrepreneurs aged 25-45. People looking to learn who prefer practical, actionable content over theory.'
  )
ON CONFLICT ("language", "name") DO NOTHING;

-- Grant API access so PostgREST can expose this table
GRANT ALL ON "DefaultContentProfile" TO anon, authenticated, service_role;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
