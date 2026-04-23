type Sentiment = 'Positive' | 'Neutral' | 'Negative';

export type AnalysisResult = {
  response: string;
  position: number;
  sentiment: Sentiment;
  isCited: boolean;
  competitors: {
    id: string;
    position: number;
    sentiment: Sentiment;
  }[];
  citations: {
    url: string;
    title: string;
    domain: string;
  }[];
  relatedQuestions: string[];
};
