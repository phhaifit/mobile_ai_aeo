import { IsOptional, IsString } from 'class-validator';
import { Transform } from 'class-transformer';
import { IsCountryCode } from 'src/shared/decorators/is-country-code.decorator';
import { IsLanguageCode } from 'src/shared/decorators/is-language-code.decorator';
import { DEFAULT_LOCATION } from 'src/shared/constant';

export class SearchOptionDto {
  @IsLanguageCode()
  @IsString()
  @IsOptional()
  @Transform(({ value }: { value: string | undefined }) => value?.toLowerCase())
  lang?: string;

  @IsCountryCode()
  @IsString()
  @IsOptional()
  @Transform(({ value }: { value: string | undefined }) =>
    value?.toLowerCase() === DEFAULT_LOCATION.toLowerCase()
      ? DEFAULT_LOCATION
      : value?.toUpperCase(),
  )
  loc?: string;
}
