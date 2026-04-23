-- Backfill default writing styles for existing projects that have no content profiles
INSERT INTO "ContentProfile" ("projectId", "name", "description", "voiceAndTone", "audience")
SELECT p."id", d."name", d."description", d."voiceAndTone", d."audience"
FROM "Project" p
CROSS JOIN "DefaultContentProfile" d
WHERE d."language" = p."language"
  AND NOT EXISTS (
    SELECT 1 FROM "ContentProfile" cp WHERE cp."projectId" = p."id"
  );
