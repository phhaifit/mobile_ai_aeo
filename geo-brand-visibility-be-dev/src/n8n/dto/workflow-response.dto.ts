import { ApiProperty } from '@nestjs/swagger';
import { ContentInsightDto } from '../../content-insight/dto/content-insight-response.dto';

export class WorkflowResponseDto {
  @ApiProperty({
    description: 'Target keywords for the content',
    example: ['AI', 'machine learning', 'technology'],
  })
  targetKeywords: string[];

  @ApiProperty({
    description: 'Content insights from the workflow',
    type: [ContentInsightDto],
  })
  contentInsight: ContentInsightDto[];

  @ApiProperty({
    description: 'Generated content body',
    example: 'Content here...',
  })
  body: string;

  @ApiProperty({
    description: 'Generated content title',
    example: 'Title',
  })
  title: string;

  @ApiProperty({
    description: 'Success status',
    example: true,
  })
  success: boolean;
}
