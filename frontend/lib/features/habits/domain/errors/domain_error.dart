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
  final String messageKey = 'habitsNotMergedError';
}

class UnitNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'unitNotFoundError';
}

class QuantityOfSetIsNullError implements DomainError {
  @override
  final String messageKey = 'quantityOfSetIsNullError';
}

class QuantityPerSetIsNullError implements DomainError {
  @override
  final String messageKey = 'quantityPerSetIsNullError';
}

class QuantityOfSetIsNegativeError implements DomainError {
  @override
  final String messageKey = 'quantityOfSetIsNegativeError';
}

class QuantityPerSetIsNegativeError implements DomainError {
  @override
  final String messageKey = 'quantityPerSetIsNegativeError';
}

class DateTimeIsInTheFutureError implements DomainError {
  @override
  final String messageKey = 'dateTimeIsInTheFutureError';
}

class MissingDateTimeError implements DomainError {
  @override
  final String messageKey = 'missingDateTimeError';
}

class WeightIsNullError implements DomainError {
  @override
  final String messageKey = 'weightIsNullError';
}

class WeightIsNegativeError implements DomainError {
  @override
  final String messageKey = 'weightIsNegativeError';
}
