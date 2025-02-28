import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_participation_repository.dart';

class GetChallengeParticipationsUsecase {
  final ChallengeParticipationRepository challengeParticipationRepository;

  GetChallengeParticipationsUsecase(this.challengeParticipationRepository);

  Future<Either<DomainError, List<ChallengeParticipation>>> call() async {
    return await challengeParticipationRepository.getChallengeParticipations();
  }
}
