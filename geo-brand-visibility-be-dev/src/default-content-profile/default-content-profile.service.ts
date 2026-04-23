import { Injectable } from '@nestjs/common';
import { DefaultContentProfileRepository } from './default-content-profile.repository';
import { ContentProfileTemplateDto } from './dto/content-profile-template.dto';

@Injectable()
export class DefaultContentProfileService {
  constructor(
    private readonly defaultContentProfileRepository: DefaultContentProfileRepository,
  ) {}

  async getTemplatesByProjectLanguage(
    language: string,
    userId: string,
  ): Promise<ContentProfileTemplateDto[]> {
    const templates =
      await this.defaultContentProfileRepository.findDefaultTemplatesByLanguage(
        language,
      );

    return templates.map((t) => ({
      id: t.id,
      language: t.language,
      name: t.name,
      description: t.description,
      voiceAndTone: t.voiceAndTone,
      audience: t.audience,
    }));
  }
}
