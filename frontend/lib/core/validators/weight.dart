import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class WeightValidator extends FormzInput<int, DomainError> {
  const WeightValidator.pure() : super.pure(0);

  const WeightValidator.dirty([super.value = 0]) : super.dirty();

  @override
  DomainError? validator(int value) {
    if (value < 0) {
      return WeightIsNegativeError();
    }

    return null;
  }
}
