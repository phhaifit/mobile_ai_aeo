import { IsNotEmpty, IsString, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LinkSiteDto {
  @ApiProperty({
    description: 'UUID of the project to link the GSC property to',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @IsNotEmpty()
  @IsUUID()
  projectId: string;

  @ApiProperty({
    description:
      'GSC property URL exactly as it appears in Google Search Console (including trailing slash for URL-prefix properties)',
    example: 'https://example.com/',
  })
  @IsString()
  @IsNotEmpty()
  siteUrl: string;
}
