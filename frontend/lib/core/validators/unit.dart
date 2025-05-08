import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class UnitValidator extends FormzInput<String, DomainError> {
  const UnitValidator.pure() : super.pure('');

  const UnitValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    final RegExp pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (value == null || value == 'No unit selected') {
      return MissingUnitError();
    }

    // Regex pattern check
    if (pattern.hasMatch(value)) {
      return null;
    }

    return UnitNotFoundDomainError();
  }
}
