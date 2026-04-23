import { ApiProperty } from '@nestjs/swagger';

export class OcrParsedResultDto {
  @ApiProperty()
  ParsedText: string;

  @ApiProperty()
  FileParseExitCode: number;

  @ApiProperty()
  ErrorMessage: string;

  @ApiProperty()
  ErrorDetails: string;
}

export class OcrResponseDto {
  @ApiProperty({ type: [OcrParsedResultDto] })
  ParsedResults: OcrParsedResultDto[];

  @ApiProperty()
  OCRExitCode: number;

  @ApiProperty()
  IsErroredOnProcessing: boolean;

  @ApiProperty({ required: false })
  ErrorMessage?: string;

  @ApiProperty({ required: false })
  ErrorDetails?: string;

  @ApiProperty({ required: false })
  ProcessingTimeInMilliseconds?: string;

  @ApiProperty({ required: false })
  SearchablePDFURL?: string;
}
