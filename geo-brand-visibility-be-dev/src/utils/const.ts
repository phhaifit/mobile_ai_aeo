export const SUPABASE = 'SUPABASE';

export const AGENTS = {
  BRAND_CONTEXT_INITIALIZATION: 'brand_context_initialization',
  BRAND_HTML_EXTRACTION: 'brand_html_extraction',
  VISIBILITY_ANALYSIS_AGENT: 'visibility_analysis',
};

export const JOB_NAMES = {
  ANALYZE_PROJECT: 'ANALYZE_PROJECT',
  CONTENT_GENERATION: 'CONTENT_GENERATION',
  PROMPT_ANALYSIS: 'PROMPT_ANALYSIS',
  SOCIAL_PUBLISH: 'SOCIAL_PUBLISH',
};

export const TASK_STATUS = {
  PENDING: 'PENDING',
  RUNNING: 'RUNNING',
  DONE: 'DONE',
  FAILED: 'FAILED',
  PARTIAL: 'PARTIAL',
  SKIPPED: 'SKIPPED',
} as const;

export const DEFAULT_CONTENT_PROFILE = {
  ID: 'default',
  NAME: 'Default',
  VOICE_AND_TONE: 'Professional',
  AUDIENCE: 'General audience',
} as const;
