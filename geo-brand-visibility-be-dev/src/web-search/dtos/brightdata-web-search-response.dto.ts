import { ApiProperty } from '@nestjs/swagger';

export class BrightdataSearchGeneralDto {
  @ApiProperty()
  search_engine: string;

  @ApiProperty()
  query: string;

  @ApiProperty()
  results_cnt: number;

  @ApiProperty()
  search_time: number;

  @ApiProperty()
  language: string;

  @ApiProperty()
  location: string;

  @ApiProperty()
  mobile: boolean;

  @ApiProperty()
  basic_view: boolean;

  @ApiProperty()
  search_type: string;

  @ApiProperty()
  page_title: string;

  @ApiProperty()
  timestamp: string;
}

export class BrightdataSearchInputDto {
  @ApiProperty()
  original_url: string;

  @ApiProperty()
  user_agent: string;

  @ApiProperty()
  request_id: string;
}

export class BrightdataSearchNavigationDto {
  @ApiProperty()
  title: string;

  @ApiProperty()
  href: string;
}

export class BrightdataSearchOrganicExtensionDto {
  @ApiProperty()
  inline: boolean;

  @ApiProperty()
  type: string;

  @ApiProperty()
  text: string;

  @ApiProperty()
  rank: number;
}

export class BrightdataSearchOrganicDto {
  @ApiProperty()
  link: string;

  @ApiProperty()
  source: string;

  @ApiProperty()
  display_link: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  rank: number;

  @ApiProperty()
  global_rank: number;

  @ApiProperty({ type: [BrightdataSearchOrganicExtensionDto], required: false })
  extensions?: BrightdataSearchOrganicExtensionDto[];
}

export class BrightdataSearchPaginationPageDto {
  @ApiProperty()
  page: number;

  @ApiProperty()
  start: number;

  @ApiProperty()
  link: string;
}

export class BrightdataSearchPaginationDto {
  @ApiProperty({ type: [BrightdataSearchPaginationPageDto] })
  pages: BrightdataSearchPaginationPageDto[];

  @ApiProperty()
  current_page: number;

  @ApiProperty()
  next_page: number;

  @ApiProperty()
  next_page_start: number;

  @ApiProperty()
  next_page_link: string;
}

export class BrightdataSearchResponseDto {
  @ApiProperty({ type: BrightdataSearchGeneralDto })
  general: BrightdataSearchGeneralDto;

  @ApiProperty({ type: BrightdataSearchInputDto })
  input: BrightdataSearchInputDto;

  @ApiProperty({ type: [BrightdataSearchNavigationDto] })
  navigation: BrightdataSearchNavigationDto[];

  @ApiProperty({ type: [BrightdataSearchOrganicDto] })
  organic: BrightdataSearchOrganicDto[];

  @ApiProperty({ type: BrightdataSearchPaginationDto })
  pagination: BrightdataSearchPaginationDto;
}
