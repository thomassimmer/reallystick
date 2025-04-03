import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class HabitNameValidator extends FormzInput<String, DomainError> {
  const HabitNameValidator.pure() : super.pure('');

  const HabitNameValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 30) {
      return HabitNameWrongSizeError();
    }

    // No translation entered
    if (value == "No translation entered") {
      return AtLeastOneTranslationNeededError();
    }

    return null;
  }
}
