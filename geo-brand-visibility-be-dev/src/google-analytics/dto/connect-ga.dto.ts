import { IsNotEmpty, IsString, Length } from 'class-validator';

export class ConnectGaDto {
  @IsString()
  @IsNotEmpty()
  projectId: string;

  @IsString()
  @IsNotEmpty()
  code: string;

  @IsString()
  @Length(43, 128)
  codeVerifier: string;

  @IsString()
  @IsNotEmpty()
  redirectUri: string;
}
