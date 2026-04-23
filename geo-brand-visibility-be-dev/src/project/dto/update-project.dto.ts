import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ProjectStatus } from '../enum/project-status.enum';
import { IsCountryCode } from 'src/shared/decorators/is-country-code.decorator';
import { IsLanguageCode } from 'src/shared/decorators/is-language-code.decorator';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

export class UpdateProjectDto {
  @ApiProperty({
    description: 'Monitoring frequency for the project',
    example: 'weekly',
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  monitoringFrequency?: 'hourly' | 'daily' | 'weekly' | 'monthly';

  @ApiProperty({
    description: 'Project name',
    example: 'My Project',
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  name?: string;

  @ApiProperty({
    description: 'Brand name for the project',
    example: 'My Brand',
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  brandName?: string;

  @ApiProperty({
    description: 'Location for the project to track',
    example: DEFAULT_LOCATION,
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  @IsCountryCode()
  location?: string;

  @ApiProperty({
    description: 'Language for the project to track',
    example: DEFAULT_LANGUAGE,
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  @IsLanguageCode()
  language?: string;

  @ApiProperty({
    description: 'Array of model IDs associated with the project',
    example: [
      '437d2884-a459-4908-8cec-c9e9f8df8e28',
      '123e4567-e89b-12d3-a456-426614174000',
    ],
  })
  @IsOptional()
  models?: string[];

  @ApiProperty({
    description: 'Project status',
    enum: ProjectStatus,
    example: 'ACTIVE',
    required: false,
  })
  @IsEnum(ProjectStatus)
  @IsOptional()
  status?: ProjectStatus;
}
