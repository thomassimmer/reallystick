import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';

class DuplicateChallengeUsecase {
  final ChallengeRepository challengeRepository;

  DuplicateChallengeUsecase(this.challengeRepository);

  Future<Either<DomainError, Challenge>> call({
    required String challengeId,
  }) async {
    return await challengeRepository.duplicateChallenge(
      challengeId: challengeId,
    );
  }
}
