import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_repository.dart';

class GetChallengesUsecase {
  final ChallengeRepository challengeRepository;

  GetChallengesUsecase(this.challengeRepository);

  Future<Either<DomainError, List<Challenge>>> call() async {
    return await challengeRepository.getChallenges();
  }
}
