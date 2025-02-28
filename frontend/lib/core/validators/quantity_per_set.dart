import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class QuantityPerSetValidator extends FormzInput<int?, DomainError> {
  const QuantityPerSetValidator.pure() : super.pure(0);

  const QuantityPerSetValidator.dirty([super.value = 0]) : super.dirty();

  @override
  DomainError? validator(int? value) {
    if (value == null) {
      return QuantityPerSetIsNullError();
    }

    if (value < 0) {
      return QuantityPerSetIsNegativeError();
    }

    return null;
  }
}
