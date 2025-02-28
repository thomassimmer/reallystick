import 'package:reallystick/core/messages/errors/domain_error.dart';

class PublicMessageReportNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'publicMessageReportNotFoundError';
}

class PublicMessageNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'publicMessageNotFoundError';
}

class PublicMessageContentEmpty implements DomainError {
  @override
  final String messageKey = 'publicMessageContentEmpty';
}

class PublicMessageContentTooLong implements DomainError {
  @override
  final String messageKey = 'publicMessageContentTooLong';
}
