import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';

class GetChallengeDailyTrackingsUsecase {
  final ChallengeDailyTrackingRepository challengeDailyTrackingRepository;

  GetChallengeDailyTrackingsUsecase(this.challengeDailyTrackingRepository);

  Future<Either<DomainError, List<ChallengeDailyTracking>>> call(
      {required String challengeId}) async {
    return await challengeDailyTrackingRepository.getChallengeDailyTrackings(
      challengeId: challengeId,
    );
  }
}
