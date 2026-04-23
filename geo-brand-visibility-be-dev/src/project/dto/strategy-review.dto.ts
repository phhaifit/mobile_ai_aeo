import { IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class StrategyReviewDto {
  @ApiProperty({
    description: 'Set true to mark strategy as reviewed, false to clear',
    example: true,
  })
  @IsBoolean()
  reviewed: boolean;
}

export class StrategyReviewResponseDto {
  @ApiProperty({
    description: 'Timestamp when strategy was reviewed, null if not reviewed',
    example: '2026-04-20T12:00:00Z',
    nullable: true,
  })
  strategyReviewedAt: string | null;

  @ApiProperty({
    description: 'User ID of the reviewer, null if not reviewed',
    example: 'uuid-v4',
    nullable: true,
  })
  strategyReviewedById: string | null;

  @ApiProperty({
    description: 'Display name of the reviewer at the time of review',
    example: 'Jane Doe',
    nullable: true,
  })
  strategyReviewedByName: string | null;
}
