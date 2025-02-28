// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';

abstract class ChallengeDailyTrackingRepository {
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      getChallengeDailyTrackings({
    required String challengeId,
  });
  Future<Either<DomainError, ChallengeDailyTracking>>
      createChallengeDailyTracking({
    required String challengeId,
    required String habitId,
    required DateTime datetime,
    required int quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  });
  Future<Either<DomainError, ChallengeDailyTracking>>
      updateChallengeDailyTracking({
    required String challengeDailyTrackingId,
    required String habitId,
    required DateTime datetime,
    required int quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  });
  Future<Either<DomainError, void>> deleteChallengeDailyTracking({
    required String challengeDailyTrackingId,
  });
}
