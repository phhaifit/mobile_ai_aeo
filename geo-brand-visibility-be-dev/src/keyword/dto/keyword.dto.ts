export class KeywordDTO {
  id: string;
  topicId: string;
  keyword: string;
  createdAt: string;
  updatedAt: string;
  topicName?: string;
}

export class CreateKeywordsDTO {
  topicId: string;
  keywords: string[];
}

export class GenerateKeywordsDTO {
  projectId: string;
}

export class DeleteKeywordDTO {
  id: string;
}
