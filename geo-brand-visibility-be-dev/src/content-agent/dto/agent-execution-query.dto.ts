import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { Type, Transform } from 'class-transformer';
import { IsDate, IsEnum, IsOptional, IsString, IsArray } from 'class-validator';
import { AgentType } from './content-agent.dto';

export class AgentExecutionQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => {
    if (value == null) return undefined;
    return Array.isArray(value) ? value : [value];
  })
  status?: string[];

  @IsOptional()
  @IsArray()
  @IsEnum(AgentType, { each: true })
  @Transform(({ value }) => {
    if (value == null) return undefined;
    return Array.isArray(value) ? value : [value];
  })
  agentType?: AgentType[];

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startDate?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endDate?: Date;
}
