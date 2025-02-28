import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class CreateHabitUsecase {
  final HabitRepository habitRepository;

  CreateHabitUsecase(this.habitRepository);

  Future<Either<DomainError, Habit>> call({
    required Map<String, String> shortName,
    required Map<String, String> longName,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required HashSet<String> unitIds,
  }) async {
    return await habitRepository.createHabit(
      shortName: shortName,
      longName: longName,
      description: description,
      categoryId: categoryId,
      icon: icon,
      unitIds: unitIds,
    );
  }
}
