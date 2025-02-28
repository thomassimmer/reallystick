import 'package:reallystick/core/messages/errors/domain_error.dart';

class PrivateDiscussionNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'privateDiscussionNotFoundError';
}

class PrivateMessageNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'privateMessageNotFoundError';
}

class PrivateMessageContentEmpty implements DomainError {
  @override
  final String messageKey = 'privateMessageContentEmpty';
}

class PrivateMessageContentTooLong implements DomainError {
  @override
  final String messageKey = 'privateMessageContentTooLong';
}
