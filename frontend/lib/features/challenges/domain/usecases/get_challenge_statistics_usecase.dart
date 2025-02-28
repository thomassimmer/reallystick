import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_statistic_repository.dart';

class GetChallengeStatisticsUsecase {
  final ChallengeStatisticRepository challengeStatisticRepository;

  GetChallengeStatisticsUsecase(this.challengeStatisticRepository);

  Future<Either<DomainError, List<ChallengeStatistic>>> call() async {
    return await challengeStatisticRepository.getChallengeStatistics();
  }
}
