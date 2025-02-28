import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';

class DeleteChallengeUsecase {
  final ChallengeRepository challengeRepository;

  DeleteChallengeUsecase(this.challengeRepository);

  Future<Either<DomainError, void>> call({
    required String challengeId,
  }) async {
    return await challengeRepository.deleteChallenge(
      challengeId: challengeId,
    );
  }
}
