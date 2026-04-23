import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, Max, Min } from 'class-validator';

export class GenerateDailyDto {
  @ApiPropertyOptional({
    description: 'Max number of blog posts to queue',
    example: 10,
    default: 100,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  blogBatchSize?: number;

  @ApiPropertyOptional({
    description: 'Max number of social media posts to queue',
    example: 10,
    default: 100,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  socialBatchSize?: number;
}
