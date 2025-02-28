import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';

class GetChallengesDailyTrackingsUsecase {
  final ChallengeDailyTrackingRepository challengeDailyTrackingRepository;

  GetChallengesDailyTrackingsUsecase(this.challengeDailyTrackingRepository);

  Future<Either<DomainError, List<ChallengeDailyTracking>>> call(
      {required List<String> challengeIds}) async {
    return await challengeDailyTrackingRepository.getChallengesDailyTrackings(
      challengeIds: challengeIds,
    );
  }
}
