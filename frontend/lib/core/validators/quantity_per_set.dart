import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class QuantityPerSetValidator extends FormzInput<String?, DomainError> {
  const QuantityPerSetValidator.pure() : super.pure("0");

  const QuantityPerSetValidator.dirty([super.value = "0"]) : super.dirty();

  @override
  DomainError? validator(String? value) {
    if (value == null) {
      return QuantityPerSetIsNullError();
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      return QuantityIsNotANumberError();
    }

    if (parsedValue < 0) {
      return QuantityPerSetIsNegativeError();
    }

    return null;
  }
}
