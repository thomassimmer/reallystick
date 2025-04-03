// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<Either<DomainError, List<Habit>>> getHabits();
  Future<Either<DomainError, Habit>> createHabit({
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required HashSet<String> unitIds,
  });
  Future<Either<DomainError, Habit>> updateHabit({
    required String habitId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
    
  });

  Future<Either<DomainError, void>> deleteHabit({
    required String habitId,
  });

  Future<Either<DomainError, Habit>> mergeHabits({
    required String habitToDeleteId,
    required String habitToMergeOnId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
  });
}
