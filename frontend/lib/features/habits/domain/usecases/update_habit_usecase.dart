import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class UpdateHabitUsecase {
  final HabitRepository habitRepository;

  UpdateHabitUsecase(this.habitRepository);

  Future<Either<DomainError, Habit>> call({
    required String habitId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
  }) async {
    return await habitRepository.updateHabit(
      habitId: habitId,
      name: name,
      description: description,
      categoryId: categoryId,
      icon: icon,
      reviewed: reviewed,
      unitIds: unitIds,
    );
  }
}
