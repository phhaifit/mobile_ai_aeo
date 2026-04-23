import { ApiProperty } from '@nestjs/swagger';

export class BrightdataCrawlInputDto {
  @ApiProperty()
  url: string;
}

export class BrightdataCrawlDiscoveryInputDto {
  @ApiProperty()
  url: string;

  @ApiProperty()
  filter: string;

  @ApiProperty()
  exclude_filter: string;
}

export class BrightdataCrawlResponseDto {
  @ApiProperty()
  markdown: string;

  @ApiProperty()
  url: string;

  @ApiProperty()
  html2text: string;

  @ApiProperty()
  page_html: string;

  @ApiProperty({ required: false, nullable: true })
  ld_json: any;

  @ApiProperty()
  page_title: string;

  @ApiProperty()
  timestamp: string;

  @ApiProperty({ type: BrightdataCrawlInputDto })
  input: BrightdataCrawlInputDto;

  @ApiProperty({ type: BrightdataCrawlDiscoveryInputDto })
  discovery_input: BrightdataCrawlDiscoveryInputDto;
}
