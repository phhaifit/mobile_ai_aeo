import {
  registerDecorator,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
} from 'class-validator';
import ISO6391 from 'iso-639-1';

@ValidatorConstraint({ name: 'isLanguageCode', async: false })
export class IsLanguageCodeConstraint implements ValidatorConstraintInterface {
  validate(value: any) {
    if (typeof value !== 'string') return false;
    return ISO6391.validate(value.toLowerCase());
  }

  defaultMessage(args: ValidationArguments) {
    return `Invalid language code: ${args.value}`;
  }
}

export function IsLanguageCode(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsLanguageCodeConstraint,
    });
  };
}
