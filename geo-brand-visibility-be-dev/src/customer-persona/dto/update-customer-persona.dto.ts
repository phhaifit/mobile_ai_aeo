import { PartialType } from '@nestjs/swagger';
import { CreateCustomerPersonaDto } from './create-customer-persona.dto';

export class UpdateCustomerPersonaDto extends PartialType(
  CreateCustomerPersonaDto,
) {}
