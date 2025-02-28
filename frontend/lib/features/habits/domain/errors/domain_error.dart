import 'package:reallystick/core/messages/errors/domain_error.dart';

class HabitNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'habitNotFoundError';
}

class HabitParticipationNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'habitParticipationNotFoundError';
}

class HabitCategoryNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'habitCategoryNotFoundError';
}

class HabitDailyTrackingNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'habitDailyTrackingNotFoundError';
}
