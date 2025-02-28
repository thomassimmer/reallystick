import 'package:formz/formz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/errors/domain_error.dart';

class PrivateMessageContentValidator extends FormzInput<String?, DomainError> {
  const PrivateMessageContentValidator.pure() : super.pure('');

  const PrivateMessageContentValidator.dirty([super.value = ''])
      : super.dirty();

  @override
  DomainError? validator(String? value) {
    if (value == null) {
      return PrivateMessageContentEmpty();
    }

    // Length check
    if (value.length > 10000) {
      return PrivateMessageContentTooLong();
    }

    return null;
  }
}
