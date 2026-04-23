-- Migration: Add custom domain support to Brand table
-- Created: 2026-01-23

-- Add custom domain columns
ALTER TABLE "Brand" 
  ADD COLUMN IF NOT EXISTS "customDomain" TEXT,
  ADD COLUMN IF NOT EXISTS "customBlogPath" TEXT DEFAULT '/blog';

-- Ensure custom domains are unique (one brand per domain)
-- Using partial index to only enforce uniqueness for non-null values
CREATE UNIQUE INDEX IF NOT EXISTS "Brand_customDomain_unique" 
  ON "Brand" ("customDomain") 
  WHERE "customDomain" IS NOT NULL;

-- Index for fast domain lookups
CREATE INDEX IF NOT EXISTS "Brand_customDomain_idx" 
  ON "Brand" ("customDomain") 
  WHERE "customDomain" IS NOT NULL;

-- Add comment for documentation
COMMENT ON COLUMN "Brand"."customDomain" IS 'Custom domain for blog (e.g., jarvis.cx). No protocol, no path.';
COMMENT ON COLUMN "Brand"."customBlogPath" IS 'Path where blog is served on custom domain (e.g., /blog or /articles)';
