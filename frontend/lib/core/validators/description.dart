import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class DescriptionValidator extends FormzInput<String, DomainError> {
  const DescriptionValidator.pure() : super.pure('');

  const DescriptionValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 200) {
      return HabitDescriptionWrongSizeError();
    }

    // No translation entered
    if (value == "No translation entered") {
      return AtLeastOneTranslationNeededError();
    }

    return null;
  }
}
