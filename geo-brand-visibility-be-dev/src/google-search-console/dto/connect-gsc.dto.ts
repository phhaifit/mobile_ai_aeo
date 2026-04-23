import { IsNotEmpty, IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ConnectGscDto {
  @ApiProperty({
    description: 'Project ID this GSC connection belongs to',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @IsString()
  @IsNotEmpty()
  projectId: string;

  @ApiProperty({
    description:
      'OAuth authorization code returned by Google after user consent',
    example: '4/0AfJohXn...',
  })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({
    description:
      'PKCE code verifier used when initiating the OAuth flow (43–128 characters)',
    example: 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk',
    minLength: 43,
    maxLength: 128,
  })
  @IsString()
  @Length(43, 128)
  codeVerifier: string;

  @ApiProperty({
    description: 'OAuth redirect URI registered with Google Cloud Console',
    example: 'https://app.aeo.how/api/gsc/callback',
  })
  @IsString()
  @IsNotEmpty()
  redirectUri: string;
}
