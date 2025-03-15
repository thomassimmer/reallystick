// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';

abstract class ChallengeParticipationRepository {
  Future<Either<DomainError, List<ChallengeParticipation>>>
      getChallengeParticipations();
  Future<Either<DomainError, ChallengeParticipation>>
      createChallengeParticipation({
    required String challengeId,
    required String color,
    required DateTime startDate,
  });
  Future<Either<DomainError, ChallengeParticipation>>
      updateChallengeParticipation({
    required String challengeParticipationId,
    required String color,
    required DateTime startDate,
    required bool notificationsReminderEnabled,
    required String? reminderTime,
    required String? reminderBody,
    required bool finished,
  });
  Future<Either<DomainError, void>> deleteChallengeParticipation({
    required String challengeParticipationId,
  });
}
