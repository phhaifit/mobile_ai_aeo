import { ApiProperty } from '@nestjs/swagger';

export type DomainStatus =
  | 'pending'
  | 'verified'
  | 'misconfigured'
  | 'failed'
  | null;

export class DomainStatusResponseDto {
  @ApiProperty({
    description: 'Current domain verification status',
    enum: ['pending', 'verified', 'misconfigured', 'failed'],
    nullable: true,
    example: 'verified',
  })
  status: DomainStatus;

  @ApiProperty({
    description: 'Human-readable error when domain is misconfigured or failed',
    nullable: true,
    example: null,
  })
  error: string | null;
}
