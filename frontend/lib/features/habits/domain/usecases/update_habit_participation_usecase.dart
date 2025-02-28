import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';

class UpdateHabitParticipationUsecase {
  final HabitParticipationRepository habitParticipationRepository;

  UpdateHabitParticipationUsecase(this.habitParticipationRepository);

  Future<Either<DomainError, HabitParticipation>> call({
    required String habitParticipationId,
    required String color,
    required bool toGain,
  }) async {
    return await habitParticipationRepository.updateHabitParticipation(
      habitParticipationId: habitParticipationId,
      color: color,
      toGain: toGain,
    );
  }
}
