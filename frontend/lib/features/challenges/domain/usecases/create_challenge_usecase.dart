import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';

class CreateChallengeUsecase {
  final ChallengeRepository challengeRepository;

  CreateChallengeUsecase(this.challengeRepository);

  Future<Either<DomainError, Challenge>> call({
    required Map<String, String> name,
    required Map<String, String> description,
    required String icon,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    return await challengeRepository.createChallenge(
      name: name,
      description: description,
      icon: icon,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
