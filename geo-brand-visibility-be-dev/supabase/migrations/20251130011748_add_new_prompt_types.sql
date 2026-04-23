-- Add new prompt type values
ALTER TYPE "PromptType" ADD VALUE IF NOT EXISTS 'Informational';
ALTER TYPE "PromptType" ADD VALUE IF NOT EXISTS 'Commercial';
ALTER TYPE "PromptType" ADD VALUE IF NOT EXISTS 'Transactional';
ALTER TYPE "PromptType" ADD VALUE IF NOT EXISTS 'Navigational';
