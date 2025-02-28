import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class HabitDailyTrackingDatetime extends FormzInput<DateTime?, DomainError> {
  const HabitDailyTrackingDatetime.pure() : super.pure(null);
  const HabitDailyTrackingDatetime.dirty([super.value]) : super.dirty();

  @override
  DomainError? validator(DateTime? value) {
    if (value == null) {
      return MissingDateTimeError();
    }

    final currentTime = DateTime.now().add(Duration(minutes: 1));
    if (value.isAfter(currentTime)) {
      return DateTimeIsInTheFutureError();
    }

    return null;
  }
}
