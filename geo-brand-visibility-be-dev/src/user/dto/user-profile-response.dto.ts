import { ApiProperty } from '@nestjs/swagger';

export class UserProfileResponseDTO {
  @ApiProperty({
    description: 'Unique identifier for the user',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  id: string;

  @ApiProperty({
    description: 'Full name of the user',
    example: 'John Doe',
    type: String,
  })
  fullname: string;

  @ApiProperty({
    description: 'Email address of the user',
    example: 'example@gmail.com',
    type: String,
  })
  email: string;

  @ApiProperty({
    description: 'URL of the user avatar image',
    example: 'https://example.com/avatar.jpg',
    type: String,
    nullable: true,
  })
  avatar: string | null;

  @ApiProperty({
    description: 'Whether the user has completed or skipped the product tour',
    example: false,
    type: Boolean,
  })
  hasSeenTour: boolean;
}
