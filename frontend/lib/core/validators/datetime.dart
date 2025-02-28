import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class DateTimeValidator extends FormzInput<DateTime?, DomainError> {
  const DateTimeValidator.pure() : super.pure(null);
  const DateTimeValidator.dirty([super.value]) : super.dirty();

  @override
  DomainError? validator(DateTime? value) {
    if (value == null) {
      return MissingDateTimeError();
    }

    final currentTime = DateTime.now();
    if (value.isAfter(currentTime)) {
      return DateTimeIsInTheFutureError();
    }

    return null;
  }
}
