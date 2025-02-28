import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';

class ChallengeDailyTrackingNoteValidator
    extends FormzInput<String?, DomainError> {
  const ChallengeDailyTrackingNoteValidator.pure() : super.pure('');

  const ChallengeDailyTrackingNoteValidator.dirty([super.value = ''])
      : super.dirty();

  @override
  DomainError? validator(String? value) {
    // Length check
    if (value != null && value.length > 100) {
      return ChallengeDailyTrackingNoteTooLong();
    }

    return null;
  }
}
