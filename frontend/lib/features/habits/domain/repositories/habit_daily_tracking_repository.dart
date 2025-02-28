// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';

abstract class HabitDailyTrackingRepository {
  Future<Either<DomainError, List<HabitDailyTracking>>> getHabitDailyTracking();
  Future<Either<DomainError, HabitDailyTracking>> createHabitDailyTracking({
    required String habitId,
    required DateTime day,
    required Duration? duration,
    required int? quantityPerSet,
    required int? quantityOfSet,
    required String? unit,
    required bool reset,
  });
  Future<Either<DomainError, HabitDailyTracking>> updateHabitDailyTracking({
    required String habitDailyTrackingId,
    required DateTime day,
    required Duration? duration,
    required int? quantityPerSet,
    required int? quantityOfSet,
    required String? unit,
    required bool reset,
  });
  Future<Either<DomainError, void>> deleteHabitDailyTracking({
    required String habitDailyTrackingId,
  });
}
