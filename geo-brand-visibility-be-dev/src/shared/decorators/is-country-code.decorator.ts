import {
  registerDecorator,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
} from 'class-validator';
import iso3166 from 'iso-3166-1';
import { DEFAULT_LOCATION } from '../constant';

@ValidatorConstraint({ name: 'isCountryCode', async: false })
export class IsCountryCodeConstraint implements ValidatorConstraintInterface {
  validate(value: any) {
    if (typeof value !== 'string') return false;
    if (value.toLowerCase() === DEFAULT_LOCATION.toLowerCase()) return true;
    return !!iso3166.whereAlpha2(value.toUpperCase());
  }

  defaultMessage(args: ValidationArguments) {
    return `Invalid country code: ${args.value}`;
  }
}

export function IsCountryCode(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsCountryCodeConstraint,
    });
  };
}
