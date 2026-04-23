export interface ReportData {
  projectName: string;
  brandName: string;
  executionDate: string;

  summary: {
    brandVisibilityScore: number;
    brandMentionsRate: number;
    brandMentionsRateDelta: number | null;
    linkReferencesRate: number;
    linkReferencesRateDelta: number | null;
    promptGeneration: {
      newPromptsCreated: number;
      newPromptsMentioningBrand: number;
    };
    contentGeneration: {
      newContentCreated: number;
      systemGeneratedContent: number;
      userCreatedContent: number;
      socialMediaPublishedContent: number;
    };
  };

  competitorRanks: {
    name: string;
    mentionRate: number;
  }[];

  platformBreakdown: {
    name: string;
    mentionRate: number;
  }[];

  promptsMentioningBrand: {
    content: string;
    ranking: number;
    url: string;
  }[];

  topReferencedDomains: {
    domain: string;
    frequency: number;
  }[];

  overviewUrl: string;
}
