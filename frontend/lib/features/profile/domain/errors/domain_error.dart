import 'package:reallystick/core/messages/errors/domain_error.dart';

class PasswordNotExpiredDomainError implements DomainError {
  @override
  final String messageKey = 'passwordNotExpiredError';
}
