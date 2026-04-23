-- Add CANCELLED to SocialPostTarget status check constraint
ALTER TABLE "SocialPostTarget"
DROP CONSTRAINT "SocialPostTarget_status_check";

ALTER TABLE "SocialPostTarget"
ADD CONSTRAINT "SocialPostTarget_status_check"
CHECK (status IN ('PENDING', 'QUEUED', 'PUBLISHING', 'PUBLISHED', 'FAILED', 'CANCELLED'));
