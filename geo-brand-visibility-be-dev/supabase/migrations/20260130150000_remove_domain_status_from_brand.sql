-- Remove domainStatus column from Brand table (no longer needed after removing domain status tracking)
ALTER TABLE "Brand" 
  DROP COLUMN IF EXISTS "domainStatus";
