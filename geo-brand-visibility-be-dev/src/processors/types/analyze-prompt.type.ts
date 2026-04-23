export type AnalyzePromptJob = {
  prompt: {
    id: string;
    content: string;
    projectId: string;
    models: {
      id: string;
      name: string;
    }[];
    brand: {
      id: string;
      name: string;
      industry: string;
      domain: string;
    };
  };
  taskId: string;
  userId: string;
};
