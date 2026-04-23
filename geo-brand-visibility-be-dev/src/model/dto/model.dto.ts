import { ApiProperty } from '@nestjs/swagger';

export class ModelDto {
  @ApiProperty({
    description: 'Unique identifier of the model',
    example: '437d2884-a459-4908-8cec-c9e9f8df8e28',
  })
  id: string;

  @ApiProperty({
    description: 'Name of the model',
    example: 'ChatGPT',
  })
  name: string;

  @ApiProperty({
    description: 'Description of the model',
    example: 'A large language model developed by OpenAI',
  })
  description: string;
}
