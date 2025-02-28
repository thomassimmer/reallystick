import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';

class UpdateChallengeUsecase {
  final ChallengeRepository challengeRepository;

  UpdateChallengeUsecase(this.challengeRepository);

  Future<Either<DomainError, Challenge>> call({
    required String challengeId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String icon,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    return await challengeRepository.updateChallenge(
      challengeId: challengeId,
      name: name,
      description: description,
      icon: icon,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
