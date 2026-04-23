import { IsNotEmpty, IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GoogleLoginRequestDto {
  @ApiProperty({
    description:
      'The authorization code returned by Google OAuth2.0 consent screen',
    example: '4/0AfJohXkBE-YXu...truncated...Ya_2DMg',
    type: String,
    required: true,
  })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({
    description:
      'PKCE code verifier that was used to generate the code challenge in the initial authorization request',
    example: 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk',
    type: String,
    required: true,
    minLength: 43,
    maxLength: 128,
  })
  @IsString()
  @IsNotEmpty()
  @Length(43, 128)
  codeVerifier: string;

  @ApiProperty({
    description:
      'The redirect URI that was used in the initial authorization request',
    example: 'http://localhost:3000/auth/google/callback',
    type: String,
    required: true,
  })
  @IsString()
  @IsNotEmpty()
  redirectUri: string;
}
