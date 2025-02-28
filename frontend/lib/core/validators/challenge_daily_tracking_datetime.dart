import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class ChallengeDailyTrackingDatetime
    extends FormzInput<DateTime?, DomainError> {
  const ChallengeDailyTrackingDatetime.pure() : super.pure(null);
  const ChallengeDailyTrackingDatetime.dirty([super.value]) : super.dirty();

  @override
  DomainError? validator(DateTime? value) {
    if (value == null) {
      return MissingDateTimeError();
    }

    final currentTime = DateTime.now().subtract(Duration(minutes: 1));
    if (value.isBefore(currentTime)) {
      return DateTimeIsInThePastError();
    }

    return null;
  }
}
