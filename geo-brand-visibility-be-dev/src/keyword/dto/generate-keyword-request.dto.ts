import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsNotEmpty, IsString } from 'class-validator';

export class GenerateKeywordRequestDTO {
  @ApiProperty({
    description: 'The topic id',
    example: 'topic-1',
    type: 'string',
  })
  @IsNotEmpty()
  @IsString()
  topicId: string;

  @ApiProperty({
    description: 'The keyword text',
    example: 'AI Tools',
    type: 'string',
  })
  @IsNotEmpty()
  @IsArray()
  @IsString({ each: true })
  keywords: string[];
}
