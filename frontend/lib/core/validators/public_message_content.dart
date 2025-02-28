import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/errors/domain_error.dart';

class PublicMessageContentValidator extends FormzInput<String?, DomainError> {
  const PublicMessageContentValidator.pure() : super.pure('');

  const PublicMessageContentValidator.dirty([super.value = '']) : super.dirty();

  @override
  DomainError? validator(String? value) {
    if (value == null) {
      return PublicMessageContentEmpty();
    }

    // Length check
    if (value.length > 2000) {
      return PublicMessageContentTooLong();
    }

    return null;
  }
}
