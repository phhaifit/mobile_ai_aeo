import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty } from 'class-validator';

export class AnswerInvitationDto {
  @ApiProperty({
    description: 'Answer to the invitation',
    example: true,
  })
  @IsBoolean()
  @IsNotEmpty()
  answer: boolean;
}
