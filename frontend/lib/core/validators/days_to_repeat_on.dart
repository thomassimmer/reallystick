import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';

class RepeatValidator extends FormzInput<Set<int>?, DomainError> {
  const RepeatValidator.pure() : super.pure(null);

  const RepeatValidator.dirty([super.value]) : super.dirty();

  @override
  DomainError? validator(Set<int>? value) {
    if (value == null || value.any((day) => day == 0)) {
      return RepetitionNumberIsNullError();
    }

    if (value.any((day) => day < 0)) {
      return RepetitionNumberIsNegativeError();
    }

    return null;
  }
}
