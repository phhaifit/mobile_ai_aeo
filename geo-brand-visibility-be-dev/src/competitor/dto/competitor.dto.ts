import { ApiProperty } from '@nestjs/swagger';

export class CompetitorDTO {
  @ApiProperty({
    description: 'Unique identifier of the competitor',
    example: 'uuid-v4',
  })
  id: string;

  @ApiProperty({
    description: 'Name of the competitor',
    example: 'Competitor Name',
  })
  name: string;

  @ApiProperty({
    description: 'Description of the competitor',
    example: 'A brief description of the competitor',
    required: false,
  })
  description?: string;

  @ApiProperty({
    description: 'Indicates if the competitor is selected',
    example: true,
  })
  isSelected: boolean;
}
