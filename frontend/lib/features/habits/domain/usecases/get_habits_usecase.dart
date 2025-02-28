import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class GetHabitsUsecase {
  final HabitRepository habitRepository;

  GetHabitsUsecase(this.habitRepository);

  Future<Either<DomainError, List<Habit>>> call() async {
    return await habitRepository.getHabits();
  }
}
