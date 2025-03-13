// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';

abstract class HabitParticipationRepository {
  Future<Either<DomainError, List<HabitParticipation>>>
      getHabitParticipations();
  Future<Either<DomainError, HabitParticipation>> createHabitParticipation({
    required String habitId,
    required String color,
    required bool toGain,
  });
  Future<Either<DomainError, HabitParticipation>> updateHabitParticipation({
    required String habitParticipationId,
    required String color,
    required bool toGain,
    required bool notificationsReminderEnabled,
    required String? reminderTime,
    required String? reminderBody,
  });
  Future<Either<DomainError, void>> deleteHabitParticipation({
    required String habitParticipationId,
  });
}
