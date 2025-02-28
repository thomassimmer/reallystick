import 'package:reallystick/core/messages/errors/domain_error.dart';

class ChallengeNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'challengeNotFoundError';
}

class ChallengeParticipationNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'challengeParticipationNotFoundError';
}

class ChallengeDailyTrackingNotFoundDomainError implements DomainError {
  @override
  final String messageKey = 'challengeDailyTrackingNotFoundError';
}

class DateTimeIsInThePastError implements DomainError {
  @override
  final String messageKey = 'dateTimeIsInThePastError';
}

class ChallengeNameWrongSizeError implements DomainError {
  @override
  final String messageKey = 'challengeNameWrongSizeError';
}

class RepetitionNumberIsNullError implements DomainError {
  @override
  final String messageKey = 'repetitionNumberIsNullError';
}

class RepetitionNumberIsNegativeError implements DomainError {
  @override
  final String messageKey = 'repetitionNumberIsNegativeError';
}

class ChallengeDailyTrackingNoteTooLong implements DomainError {
  @override
  final String messageKey = 'challengeDailyTrackingNoteTooLong';
}
