import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';

class RepeatValidator extends FormzInput<int?, DomainError> {
  const RepeatValidator.pure() : super.pure(0);

  const RepeatValidator.dirty([super.value = 0]) : super.dirty();

  @override
  DomainError? validator(int? value) {
    if (value == null || value == 0) {
      return RepetitionNumberIsNullError();
    }

    if (value < 0) {
      return RepetitionNumberIsNegativeError();
    }

    return null;
  }
}
