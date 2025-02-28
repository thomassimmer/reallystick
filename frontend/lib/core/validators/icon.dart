import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class IconValidator extends FormzInput<String, DomainError> {
  const IconValidator.pure() : super.pure('');

  const IconValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty) {
      return IconEmptyError();
    }

    if (value.length > 10) {
      return IconNotFoundError();
    }

    return null;
  }
}
