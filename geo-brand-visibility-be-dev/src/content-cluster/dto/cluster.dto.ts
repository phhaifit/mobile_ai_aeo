import {
  IsString,
  IsArray,
  IsOptional,
  IsIn,
  IsNotEmpty,
  ValidateNested,
  ArrayMinSize,
  Validate,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class GenerateClusterPlanDto {
  @ApiProperty({ description: 'Topic ID to generate cluster plan for' })
  @IsString()
  @IsNotEmpty()
  topicId: string;

  @ApiProperty({
    description: 'Content profile ID for writing style',
    required: false,
  })
  @IsString()
  @IsOptional()
  profileId?: string;
}

export class ClusterPlanArticleDto {
  @ApiProperty({ description: 'Article title' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ description: 'Article role', enum: ['PILLAR', 'SATELLITE'] })
  @IsIn(['PILLAR', 'SATELLITE'])
  role: 'PILLAR' | 'SATELLITE';

  @ApiProperty({ description: 'Section headings for the article outline' })
  @IsArray()
  @IsString({ each: true })
  outline: string[];

  @ApiProperty({ description: 'Target keywords for this article' })
  @IsArray()
  @IsString({ each: true })
  targetKeywords: string[];

  @ApiProperty({ description: 'Suggested URL slug', required: false })
  @IsString()
  @IsOptional()
  suggestedSlug?: string;
}

@ValidatorConstraint({ name: 'exactlyOnePillar', async: false })
class ExactlyOnePillarConstraint implements ValidatorConstraintInterface {
  validate(articles: ClusterPlanArticleDto[]) {
    if (!Array.isArray(articles)) return false;
    return articles.filter((a) => a.role === 'PILLAR').length === 1;
  }

  defaultMessage() {
    return 'Articles must contain exactly one PILLAR article';
  }
}

export class GenerateClusterArticlesDto {
  @ApiProperty({ description: 'Topic ID' })
  @IsString()
  @IsNotEmpty()
  topicId: string;

  @ApiProperty({
    description: 'Content profile ID for writing style',
    required: false,
  })
  @IsString()
  @IsOptional()
  profileId?: string;

  @ApiProperty({
    description: 'List of articles to generate',
    type: [ClusterPlanArticleDto],
  })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ClusterPlanArticleDto)
  @Validate(ExactlyOnePillarConstraint)
  articles: ClusterPlanArticleDto[];
}
