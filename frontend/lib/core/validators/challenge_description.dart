import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class ChallengeDescriptionValidator extends FormzInput<String, DomainError> {
  const ChallengeDescriptionValidator.pure() : super.pure('');

  const ChallengeDescriptionValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value == null || value.isEmpty || value.length > 2000) {
      return ChallengeDescriptionWrongSize();
    }

    // No translation entered
    if (value == "No translation entered") {
      return AtLeastOneTranslationNeededError();
    }

    return null;
  }
}
