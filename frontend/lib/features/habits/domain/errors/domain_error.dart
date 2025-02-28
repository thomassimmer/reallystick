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

class HabitShortNameWrongSizeError implements DomainError {
  @override
  final String messageKey = 'habitShortNameWrongSizeError';
}

class HabitLongNameWrongSizeError implements DomainError {
  @override
  final String messageKey = 'habitLongNameWrongSizeError';
}

class HabitDescriptionWrongSizeError implements DomainError {
  @override
  final String messageKey = 'habitDescriptionWrongSizeError';
}

class HabitIconNotFoundError implements DomainError {
  @override
  final String messageKey = 'habitIconNotFoundError';
}

class HabitsNotMergedDomainError implements DomainError {
  @override
  final String messageKey = 'habitsNotMergedDomainError';
}
