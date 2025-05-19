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
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      getChallengesDailyTrackings({required List<String> challengeIds});
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      createChallengeDailyTracking({
    required String challengeId,
    required String habitId,
    required int dayOfProgram,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
    required String? note,
    required Set<int> daysToRepeatOn,
    required int orderInDay,
  });
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      updateChallengeDailyTracking({
    required String challengeDailyTrackingId,
    required String habitId,
    required int dayOfProgram,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
    required String? note,
    required Set<int> daysToRepeatOn,
    required int orderInDay,
  });
  Future<Either<DomainError, void>> deleteChallengeDailyTracking({
    required String challengeDailyTrackingId,
  });
}
