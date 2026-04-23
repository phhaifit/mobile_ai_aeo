import { ApiProperty } from '@nestjs/swagger';

export class SignupResponseDto {
  @ApiProperty({
    description: 'Whether the signup was successful',
    example: true,
  })
  success: boolean;

  @ApiProperty({
    description: 'Message describing the result of the signup operation',
    example:
      'User registered successfully. Please check your email for verification.',
  })
  message: string;

  @ApiProperty({
    description: 'ID of the newly created user',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  userId: string;
}
