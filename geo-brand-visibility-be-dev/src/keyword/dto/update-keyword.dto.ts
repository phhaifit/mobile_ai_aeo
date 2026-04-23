import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateKeywordRequestDTO {
  @ApiProperty({
    description: 'The keyword text',
    example: 'AI Tools',
    type: 'string',
  })
  @IsNotEmpty()
  @IsString()
  keyword: string;
}

export class UpdateKeywordResponseDTO {
  id: string;
  topicId: string;
  keyword: string;
  createdAt: string;
  updatedAt: string;
}
