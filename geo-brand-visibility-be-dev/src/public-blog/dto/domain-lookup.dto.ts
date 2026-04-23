import { ApiProperty } from '@nestjs/swagger';

export class DomainLookupDto {
  @ApiProperty({
    description: 'Brand display name',
    example: 'Jarvis',
  })
  brandName: string;

  @ApiProperty({
    description: 'Brand slug used for URL routing',
    example: 'jarvis',
  })
  brandSlug: string;
}
