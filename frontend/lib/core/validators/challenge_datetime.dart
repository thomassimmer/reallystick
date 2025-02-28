import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';

class ChallengeDatetime extends FormzInput<DateTime?, DomainError> {
  const ChallengeDatetime.pure() : super.pure(null);
  const ChallengeDatetime.dirty([super.value]) : super.dirty();

  @override
  DomainError? validator(DateTime? value) {
    final currentTime = DateTime.now().subtract(Duration(minutes: 1));
    if (value != null && value.isBefore(currentTime)) {
      return DateTimeIsInThePastError();
    }

    return null;
  }
}
