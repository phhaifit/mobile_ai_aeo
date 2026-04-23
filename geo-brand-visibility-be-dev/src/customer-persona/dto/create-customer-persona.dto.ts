import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsObject,
  IsBoolean,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCustomerPersonaDto {
  @ApiProperty({
    description: 'Persona name',
    example: 'Marketing Manager Mai',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Free-form description of this persona',
    example:
      'A mid-level marketing professional looking for data-driven content tools',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description:
      'Demographics: ageRange, gender, location, educationLevel, incomeRange',
    example: {
      ageRange: '30-40',
      gender: 'Female',
      location: 'Ho Chi Minh City, Vietnam',
      educationLevel: "Bachelor's degree",
      incomeRange: '$30k-$50k',
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  demographics?: Record<string, string>;

  @ApiProperty({
    description:
      'Professional background: jobTitle, industry, companySize, seniorityLevel',
    example: {
      jobTitle: 'Marketing Manager',
      industry: 'SaaS / Technology',
      companySize: '50-200 employees',
      seniorityLevel: 'Mid-level',
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  professional?: Record<string, string>;

  @ApiProperty({
    description: 'Goals and motivations of this persona',
    example:
      'Prove content marketing ROI to leadership, grow organic traffic 3x',
    required: false,
  })
  @IsString()
  @IsOptional()
  goalsAndMotivations?: string;

  @ApiProperty({
    description: 'Pain points and challenges this persona faces',
    example:
      'Struggles to produce consistent content, lacks SEO expertise, limited budget',
    required: false,
  })
  @IsString()
  @IsOptional()
  painPoints?: string;

  @ApiProperty({
    description:
      'Content preferences: channels (array), formats (array), researchHabits',
    example: {
      channels: ['LinkedIn', 'Google Search', 'Industry blogs'],
      formats: ['Long-form articles', 'Case studies'],
      researchHabits: 'Reads during commute, bookmarks for later',
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  contentPreferences?: Record<string, unknown>;

  @ApiProperty({
    description:
      'Buying behavior: triggers (array), objections (array), evaluationCriteria (array)',
    example: {
      triggers: ['Free trial available', 'Peer recommendation'],
      objections: ['Too expensive', 'Hard to integrate'],
      evaluationCriteria: ['Ease of use', 'ROI proof', 'Customer support'],
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  buyingBehavior?: Record<string, unknown>;

  @ApiProperty({
    description: 'Whether this is the primary/default persona for the brand',
    example: false,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  isPrimary?: boolean;
}
