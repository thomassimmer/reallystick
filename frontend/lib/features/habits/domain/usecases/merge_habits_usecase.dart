import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class MergeHabitsUsecase {
  final HabitRepository habitRepository;

  MergeHabitsUsecase(this.habitRepository);

  Future<Either<DomainError, Habit>> call({
    required String habitToDeleteId,
    required String habitToMergeOnId,
    required Map<String, String> shortName,
    required Map<String, String> longName,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
  }) async {
    return await habitRepository.mergeHabits(
      habitToDeleteId: habitToDeleteId,
      habitToMergeOnId: habitToMergeOnId,
      shortName: shortName,
      longName: longName,
      description: description,
      categoryId: categoryId,
      icon: icon,
      reviewed: reviewed,
      unitIds: unitIds,
    );
  }
}
