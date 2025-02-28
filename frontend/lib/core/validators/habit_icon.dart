import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class HabitIconValidator extends FormzInput<String, DomainError> {
  const HabitIconValidator.pure() : super.pure('');

  const HabitIconValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 10) {
      return HabitIconNotFoundError();
    }

    return null;
  }
}
