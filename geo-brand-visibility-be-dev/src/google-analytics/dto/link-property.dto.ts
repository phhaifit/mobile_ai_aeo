import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class LinkPropertyDto {
  @IsNotEmpty()
  @IsUUID()
  projectId: string;

  @IsString()
  @IsNotEmpty()
  propertyId: string;
}
