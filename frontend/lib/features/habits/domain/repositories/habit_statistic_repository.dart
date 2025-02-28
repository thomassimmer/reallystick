// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_statistic.dart';

abstract class HabitStatisticRepository {
  Future<Either<DomainError, List<HabitStatistic>>> getHabitStatistics();
}
