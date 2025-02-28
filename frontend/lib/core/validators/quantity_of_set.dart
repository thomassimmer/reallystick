import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class QuantityOfSetValidator extends FormzInput<int?, DomainError> {
  const QuantityOfSetValidator.pure() : super.pure(0);

  const QuantityOfSetValidator.dirty([super.value = 0]) : super.dirty();

  @override
  DomainError? validator(int? value) {
    if (value == null || value == 0) {
      return QuantityOfSetIsNullError();
    }

    if (value < 0) {
      return QuantityOfSetIsNegativeError();
    }

    return null;
  }
}
