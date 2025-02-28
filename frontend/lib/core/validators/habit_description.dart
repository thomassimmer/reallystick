import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class HabitDescriptionValidator extends FormzInput<String, DomainError> {
  const HabitDescriptionValidator.pure() : super.pure('');

  const HabitDescriptionValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 200) {
      return HabitDescriptionWrongSizeError();
    }

    return null;
  }
}
