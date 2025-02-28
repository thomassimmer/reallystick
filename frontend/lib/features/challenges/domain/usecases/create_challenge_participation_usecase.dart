import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_participation_repository.dart';

class CreateChallengeParticipationUsecase {
  final ChallengeParticipationRepository challengeParticipationRepository;

  CreateChallengeParticipationUsecase(this.challengeParticipationRepository);

  Future<Either<DomainError, ChallengeParticipation>> call({
    required String challengeId,
    required String color,
    required DateTime startDate,
  }) async {
    return await challengeParticipationRepository.createChallengeParticipation(
      challengeId: challengeId,
      color: color,
      startDate: startDate,
    );
  }
}
