import 'package:reallystick/core/messages/errors/domain_error.dart';

class NotificationNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'notificationNotFoundError';
}

class NotificationParticipationNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'notificationParticipationNotFoundError';
}

class NotificationDailyTrackingNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'notificationDailyTrackingNotFoundError';
}

class DateTimeIsInThePastError implements DomainError {
  @override
  final String messageKey = 'dateTimeIsInThePastError';
}

class NotificationNameWrongSizeError implements DomainError {
  @override
  final String messageKey = 'notificationNameWrongSizeError';
}

class RepetitionNumberIsNullError implements DomainError {
  @override
  final String messageKey = 'repetitionNumberIsNullError';
}

class RepetitionNumberIsNegativeError implements DomainError {
  @override
  final String messageKey = 'repetitionNumberIsNegativeError';
}

class NotificationDailyTrackingNoteTooLong implements DomainError {
  @override
  final String messageKey = 'notificationDailyTrackingNoteTooLong';
}
