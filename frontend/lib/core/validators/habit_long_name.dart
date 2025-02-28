import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class HabitLongNameValidator extends FormzInput<String, DomainError> {
  const HabitLongNameValidator.pure() : super.pure('');

  const HabitLongNameValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 100) {
      return HabitLongNameWrongSizeError();
    }

    return null;
  }
}
