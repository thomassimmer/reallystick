import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';

class ChallengeDailyTrackingDatetime extends FormzInput<int, DomainError> {
  const ChallengeDailyTrackingDatetime.pure() : super.pure(0);
  const ChallengeDailyTrackingDatetime.dirty([super.value = 0]) : super.dirty();

  @override
  DomainError? validator(int value) {
    if (value < 0) {
      return DateTimeIsInThePastError();
    }

    return null;
  }
}
