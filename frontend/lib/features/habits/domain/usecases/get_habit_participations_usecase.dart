import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';

class GetHabitParticipationsUsecase {
  final HabitParticipationRepository habitParticipationRepository;

  GetHabitParticipationsUsecase(this.habitParticipationRepository);

  Future<Either<DomainError, List<HabitParticipation>>> call() async {
    return await habitParticipationRepository.getHabitParticipations();
  }
}
