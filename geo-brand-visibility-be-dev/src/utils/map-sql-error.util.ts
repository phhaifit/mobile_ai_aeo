import { PostgrestError } from '@supabase/supabase-js';
import {
  BadRequestException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';

const ErrorCode = {
  NOT_NULL_VIOLATION: '23502',
  FOREIGN_KEY_VIOLATION: '23503',
  UNIQUE_VIOLATION: '23505',
  INVALID_TEXT_REPRESENTATION: '22P02',
};

export function mapSqlError(error: PostgrestError): Error {
  switch (error.code) {
    case ErrorCode.FOREIGN_KEY_VIOLATION:
      return new BadRequestException(error.message);
    case ErrorCode.NOT_NULL_VIOLATION:
      return new BadRequestException(error.message);
    case ErrorCode.UNIQUE_VIOLATION:
      return new ConflictException(error.message);
    case ErrorCode.INVALID_TEXT_REPRESENTATION:
      return new BadRequestException(error.message);
    default:
      return new InternalServerErrorException(error.message);
  }
}
