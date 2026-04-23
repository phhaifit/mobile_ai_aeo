import {
  IsArray,
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUUID,
} from 'class-validator';

export class SuggestKeywordRequestDTO {
  @IsArray()
  @IsString({ each: true })
  @IsNotEmpty()
  keywords: string[];

  @IsOptional()
  @IsUUID()
  projectId?: string;

  @IsOptional()
  @IsUUID()
  topicId?: string;
}
