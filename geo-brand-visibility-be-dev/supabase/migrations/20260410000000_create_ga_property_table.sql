-- GaProperty: links a GA4 property to a project (1:1 with Project)
CREATE TABLE "GaProperty" (
  "id"          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "projectId"   UUID NOT NULL UNIQUE REFERENCES "Project"("id") ON DELETE CASCADE,
  "userId"      UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
  "propertyId"  TEXT NOT NULL,
  "displayName" TEXT,
  "createdAt"   TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt"   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ga_property_project ON "GaProperty"("projectId");
CREATE INDEX idx_ga_property_user ON "GaProperty"("userId");

DROP TRIGGER IF EXISTS update_ga_property_updatedAt ON "GaProperty";
CREATE TRIGGER update_ga_property_updatedAt
  BEFORE UPDATE ON "GaProperty"
  FOR EACH ROW
  EXECUTE FUNCTION update_updatedAt_column();
