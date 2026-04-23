import { ApiProperty } from '@nestjs/swagger';
export class ExternalPhotoDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  smallUrl: string;

  @ApiProperty()
  regularUrl: string;

  @ApiProperty()
  fullUrl: string;

  @ApiProperty({ nullable: true })
  altDescription: string | null;

  @ApiProperty()
  photographer: {
    name: string;
    username: string;
  };

  @ApiProperty({ nullable: true })
  description: string | null;
}
