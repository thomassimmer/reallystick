import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class UpdateHabitUsecase {
  final HabitRepository habitRepository;

  UpdateHabitUsecase(this.habitRepository);

  Future<Either<DomainError, Habit>> call({
    required String habitId,
    required Map<String, String> shortName,
    required Map<String, String> longName,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
  }) async {
    return await habitRepository.updateHabit(
      habitId: habitId,
      shortName: shortName,
      longName: longName,
      description: description,
      categoryId: categoryId,
      icon: icon,
      reviewed: reviewed,
    );
  }
}
