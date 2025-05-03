import 'package:reallystick/core/messages/errors/domain_error.dart';

class HabitIsEmptyDomainError implements DomainError {
  @override
  final String messageKey = 'habitIsEmptyError';
}

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

class HabitNameWrongSizeError implements DomainError {
  @override
  final String messageKey = 'habitNameWrongSizeError';
}

class HabitDescriptionWrongSize implements DomainError {
  @override
  final String messageKey = 'habitDescriptionWrongSize';
}

class IconNotFoundError implements DomainError {
  @override
  final String messageKey = 'iconNotFoundError';
}

class IconEmptyError implements DomainError {
  @override
  final String messageKey = 'iconEmptyError';
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

class QuantityIsNotANumberError implements DomainError {
  @override
  final String messageKey = 'quantityIsNotANumberError';
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

class WeightIsNegativeError implements DomainError {
  @override
  final String messageKey = 'weightIsNegativeError';
}

class AtLeastOneTranslationNeededError implements DomainError {
  @override
  final String messageKey = 'atLeastOneTranslationNeededError';
}
