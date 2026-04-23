import { AnalyzeProjectJob } from './analyze-project.type';

export interface ContentGenerationJob extends Omit<AnalyzeProjectJob, 'userId'> {
  userId?: string;
  promptId: string;
  contentType?: string;
  contentProfileId?: string;
  keywords?: string[];
  platform?: string;
  contentAgentId?: string;
  referencePageUrl?: string;
}
