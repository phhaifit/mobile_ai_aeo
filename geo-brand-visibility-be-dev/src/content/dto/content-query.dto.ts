import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { CompletionStatus, SocialPlatform } from 'src/content/enums';
import { Transform, Type } from 'class-transformer';
import { IsArray, IsDate, IsEnum, IsOptional, IsString } from 'class-validator';
import { ContentType } from './generate-content.dto';

export class ContentQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsArray()
  @IsEnum(CompletionStatus, { each: true })
  @Transform(({ value }) => {
    if (value == null) return undefined;
    return Array.isArray(value) ? value : [value];
  })
  status?: CompletionStatus[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => {
    if (value == null) return undefined;
    return Array.isArray(value) ? value : [value];
  })
  topicName?: string[];

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startDate?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endDate?: Date;

  @IsOptional()
  @IsEnum(ContentType)
  contentType?: ContentType;

  @IsOptional()
  @IsEnum(SocialPlatform)
  platform?: SocialPlatform;
}
