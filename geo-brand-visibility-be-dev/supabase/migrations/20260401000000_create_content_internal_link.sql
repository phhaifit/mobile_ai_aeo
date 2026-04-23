-- Create ContentInternalLink junction table to track internal links between articles.
-- Populated during content generation when the internal_linking agent inserts contextual links.
CREATE TABLE "ContentInternalLink" (
  "id"                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "sourceContentId"   UUID NOT NULL REFERENCES "Content"("id") ON DELETE CASCADE,
  "targetContentId"   UUID NOT NULL REFERENCES "Content"("id") ON DELETE CASCADE,
  "anchorText"        TEXT,
  "createdAt"         TIMESTAMPTZ DEFAULT now(),
  UNIQUE("sourceContentId", "targetContentId")
);

CREATE INDEX idx_content_internal_link_source ON "ContentInternalLink"("sourceContentId");
CREATE INDEX idx_content_internal_link_target ON "ContentInternalLink"("targetContentId");
