import { Test, TestingModule } from '@nestjs/testing';
import { ContentService } from './content.service';
import { ContentRepository } from './content.repository';
import { ForbiddenException, ConflictException } from '@nestjs/common';
import { TopicRepository } from '../topic/topic.repository';
import { ProjectRepository } from '../project/project.repository';
import { BrandRepository } from '../brand/brand.repository';
import { PromptRepository } from '../prompt/prompt.repository';
import { ContentProfileRepository } from '../content-profile/content-profile.repository';
import { N8nService } from '../n8n/n8n.service';
import { WebSearchService } from '../web-search/web-search.service';
import { ContentInsightRepository } from '../content-insight/content-insight.repository';
import { CompletionStatus } from './enums';
import { ConfigService } from '@nestjs/config';

const USER_ID = 'user-1';

describe('ContentService', () => {
  let service: ContentService;
  let contentRepository: {
    findById: jest.Mock;
    findByIdWithAccess: jest.Mock;
    findManyByIdsWithAccess: jest.Mock;
    update: jest.Mock;
    deleteMany: jest.Mock;
    publishContent: jest.Mock;
    unpublishContent: jest.Mock;
  };

  beforeEach(async () => {
    contentRepository = {
      findById: jest.fn(),
      findByIdWithAccess: jest.fn(),
      findManyByIdsWithAccess: jest.fn(),
      update: jest.fn(),
      deleteMany: jest.fn(),
      publishContent: jest.fn(),
      unpublishContent: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ContentService,
        { provide: ContentRepository, useValue: contentRepository },
        { provide: TopicRepository, useValue: {} },
        { provide: ProjectRepository, useValue: {} },
        { provide: BrandRepository, useValue: {} },
        { provide: PromptRepository, useValue: {} },
        { provide: ContentProfileRepository, useValue: {} },
        { provide: N8nService, useValue: {} },
        { provide: WebSearchService, useValue: {} },
        { provide: ContentInsightRepository, useValue: {} },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              if (key === 'N8N_CALLBACK_URL') return 'http://localhost:5678';
              return null;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<ContentService>(ContentService);
  });

  describe('updateContent', () => {
    it('should throw ForbiddenException if user has no access', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue(null);

      await expect(
        service.updateContent('id', USER_ID, { title: 'New Title' }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ConflictException if trying to unpublish via update', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'PUBLISHED',
      });

      await expect(
        service.updateContent('id', USER_ID, {
          completionStatus: CompletionStatus.Drafting,
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('should throw ConflictException if trying to publish via update', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'DRAFTING',
      });

      await expect(
        service.updateContent('id', USER_ID, {
          completionStatus: CompletionStatus.Published,
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('should throw ConflictException if updating slug on published content', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'PUBLISHED',
      });

      await expect(
        service.updateContent('id', USER_ID, { slug: 'new-slug' }),
      ).rejects.toThrow(ConflictException);
    });

    it('should allow updates to non-published content', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'DRAFTING',
      });

      await service.updateContent('id', USER_ID, { title: 'New Title' });

      expect(contentRepository.update).toHaveBeenCalledWith('id', {
        title: 'New Title',
      });
    });

    it('should allow harmless updates to published content (without changing status or slug)', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'PUBLISHED',
      });

      await service.updateContent('id', USER_ID, { title: 'New Title' });

      expect(contentRepository.update).toHaveBeenCalledWith('id', {
        title: 'New Title',
      });
    });
  });

  describe('deleteContents', () => {
    it('should throw ForbiddenException if user has no access to some contents', async () => {
      contentRepository.findManyByIdsWithAccess.mockResolvedValue([
        { id: 'id-1', completionStatus: 'COMPLETE' },
      ]);

      await expect(
        service.deleteContents(['id-1', 'id-2'], USER_ID),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ConflictException if trying to delete published content', async () => {
      contentRepository.findManyByIdsWithAccess.mockResolvedValue([
        { id: 'id-1', completionStatus: 'PUBLISHED' },
      ]);

      await expect(service.deleteContents(['id-1'], USER_ID)).rejects.toThrow(
        ConflictException,
      );
    });

    it('should delete non-published contents the user has access to', async () => {
      contentRepository.findManyByIdsWithAccess.mockResolvedValue([
        { id: 'id-1', completionStatus: 'COMPLETE' },
        { id: 'id-2', completionStatus: 'DRAFTING' },
      ]);

      await service.deleteContents(['id-1', 'id-2'], USER_ID);

      expect(contentRepository.deleteMany).toHaveBeenCalledWith([
        'id-1',
        'id-2',
      ]);
    });
  });

  describe('publishContent', () => {
    it('should throw ForbiddenException if user has no access', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue(null);

      await expect(service.publishContent('id', USER_ID)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should throw ConflictException if content is not COMPLETE', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'DRAFTING',
      });

      await expect(service.publishContent('id', USER_ID)).rejects.toThrow(
        ConflictException,
      );
    });
  });

  describe('unpublishContent', () => {
    it('should throw ForbiddenException if user has no access', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue(null);

      await expect(service.unpublishContent('id', USER_ID)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should throw ConflictException if content is not PUBLISHED', async () => {
      contentRepository.findByIdWithAccess.mockResolvedValue({
        id: 'id',
        completionStatus: 'COMPLETE',
      });

      await expect(service.unpublishContent('id', USER_ID)).rejects.toThrow(
        ConflictException,
      );
    });
  });
});
