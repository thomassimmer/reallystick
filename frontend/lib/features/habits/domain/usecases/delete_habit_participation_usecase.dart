import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';

class DeleteHabitParticipationUsecase {
  final HabitParticipationRepository habitParticipationRepository;

  DeleteHabitParticipationUsecase(this.habitParticipationRepository);

  Future<Either<DomainError, void>> call({
    required String habitParticipationId,
  }) async {
    return await habitParticipationRepository.deleteHabitParticipation(
      habitParticipationId: habitParticipationId,
    );
  }
}
