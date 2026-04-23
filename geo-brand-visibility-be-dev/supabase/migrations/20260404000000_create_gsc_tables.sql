-- GoogleOAuthCredential: stores encrypted Google refresh token per user (1:1 with User)
-- Used for GSC and future Google integrations (Analytics, Ads, etc.)
CREATE TABLE "GoogleOAuthCredential" (
  "id"                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId"                UUID NOT NULL UNIQUE REFERENCES "User"("id") ON DELETE CASCADE,
  "encryptedRefreshToken" TEXT NOT NULL,
  "scopes"                TEXT[] NOT NULL DEFAULT '{}',
  "isValid"               BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt"             TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt"             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_google_oauth_credential_user ON "GoogleOAuthCredential"("userId");

DROP TRIGGER IF EXISTS update_google_oauth_credential_updatedAt ON "GoogleOAuthCredential";
CREATE TRIGGER update_google_oauth_credential_updatedAt
  BEFORE UPDATE ON "GoogleOAuthCredential"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();

-- GscProperty: links a GSC site to a project (1:1 with Project)
CREATE TABLE "GscProperty" (
  "id"              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "projectId"       UUID NOT NULL UNIQUE REFERENCES "Project"("id") ON DELETE CASCADE,
  "userId"          UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "siteUrl"         TEXT NOT NULL,
  "permissionLevel" TEXT,
  "createdAt"       TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt"       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_gsc_property_project ON "GscProperty"("projectId");
CREATE INDEX idx_gsc_property_user ON "GscProperty"("userId");

DROP TRIGGER IF EXISTS update_gsc_property_updatedAt ON "GscProperty";
CREATE TRIGGER update_gsc_property_updatedAt
  BEFORE UPDATE ON "GscProperty"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();
