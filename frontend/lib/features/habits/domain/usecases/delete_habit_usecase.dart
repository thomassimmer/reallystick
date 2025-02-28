import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class DeleteHabitUsecase {
  final HabitRepository habitRepository;

  DeleteHabitUsecase(this.habitRepository);

  Future<Either<DomainError, void>> call({
    required String habitId,
  }) async {
    return await habitRepository.deleteHabit(
      habitId: habitId,
    );
  }
}
