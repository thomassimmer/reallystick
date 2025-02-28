import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_participation_repository.dart';

class DeleteChallengeParticipationUsecase {
  final ChallengeParticipationRepository challengeParticipationRepository;

  DeleteChallengeParticipationUsecase(this.challengeParticipationRepository);

  Future<Either<DomainError, void>> call({
    required String challengeParticipationId,
  }) async {
    return await challengeParticipationRepository.deleteChallengeParticipation(
      challengeParticipationId: challengeParticipationId,
    );
  }
}
