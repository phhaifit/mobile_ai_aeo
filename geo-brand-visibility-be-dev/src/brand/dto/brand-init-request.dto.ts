import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { IsCountryCode } from 'src/shared/decorators/is-country-code.decorator';
import { IsLanguageCode } from 'src/shared/decorators/is-language-code.decorator';
import { DEFAULT_LANGUAGE } from 'src/shared/constant';

export class BrandInitRequestDto {
  @ApiProperty({
    description: 'ID of the project to which the brand belongs',
    example: 'f59db687-ebc7-4c48-b272-6c703bfd3a4c',
  })
  @IsString()
  projectId: string;

  @ApiProperty({
    description: 'Domain of the brand website',
    example: 'example.com',
  })
  @IsString()
  domain: string;

  @ApiProperty({
    description: 'Name of the project',
    example: 'Default Project',
  })
  @IsString()
  projectName: string;

  @ApiProperty({
    description: 'Name of the brand',
    example: 'Example Brand',
  })
  @IsString()
  @IsCountryCode()
  location: string;

  @ApiProperty({
    description: 'Language that the brand uses',
    example: DEFAULT_LANGUAGE,
  })
  @IsString()
  @IsLanguageCode()
  language: string;
}
