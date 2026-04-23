-- 1. Ensure Enums exist
DO $$ BEGIN
    CREATE TYPE "ProjectRole" AS ENUM ('Admin', 'Member');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "InvitationStatus" AS ENUM ('Pending', 'Accepted', 'Rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Create the Join Table (Fixed reference to "Project")
CREATE TABLE IF NOT EXISTS "Project_Member" (
  "projectId" UUID REFERENCES "Project"("id") ON DELETE CASCADE,
  "userId" UUID REFERENCES "User"("id") ON DELETE CASCADE,
  "role" "ProjectRole" DEFAULT 'Member' NOT NULL,
  "createdAt" TIMESTAMPTZ DEFAULT now(),
  "updatedAt" TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY ("projectId", "userId")
);

-- 3. Create Invitations Table (Fixed reference to "Project")
CREATE TABLE IF NOT EXISTS "Project_Invitation" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "projectId" UUID REFERENCES "Project"("id") ON DELETE CASCADE,
  "inviterId" UUID REFERENCES "User"("id") ON DELETE CASCADE,
  "inviteeId" UUID REFERENCES "User"("id") ON DELETE CASCADE,
  "role" "ProjectRole" DEFAULT 'Member' NOT NULL,
  "status" "InvitationStatus" DEFAULT 'Pending' NOT NULL,
  "createdAt" TIMESTAMPTZ DEFAULT now(),
  "expiresAt" TIMESTAMPTZ DEFAULT (now() + interval '7 days')
);