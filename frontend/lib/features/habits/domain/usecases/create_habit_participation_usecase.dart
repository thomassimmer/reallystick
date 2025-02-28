import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';

class CreateHabitParticipationUsecase {
  final HabitParticipationRepository habitParticipationRepository;

  CreateHabitParticipationUsecase(this.habitParticipationRepository);

  Future<Either<DomainError, HabitParticipation>> call({
    required String habitId,
    required String color,
    required bool toGain,
  }) async {
    return await habitParticipationRepository.createHabitParticipation(
      habitId: habitId,
      color: color,
      toGain: toGain,
    );
  }
}
