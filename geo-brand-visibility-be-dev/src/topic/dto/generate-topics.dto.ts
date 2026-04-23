import { ApiProperty } from '@nestjs/swagger';

export class GeneratedTopicDTO {
  @ApiProperty({
    description: 'The generated topic name',
    example: 'Market / Category Awareness',
  })
  name: string;

  @ApiProperty({
    description: 'Short description of the topic',
    example: 'How users search for tool categories and solution types.',
  })
  description: string;
}

export class GenerateTopicsResponseDTO {
  @ApiProperty({
    description: 'Generated topics',
    type: [GeneratedTopicDTO],
  })
  data: GeneratedTopicDTO[];
}
