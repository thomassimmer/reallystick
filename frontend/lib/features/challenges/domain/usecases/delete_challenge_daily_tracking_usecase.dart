import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';

class DeleteChallengeDailyTrackingUsecase {
  final ChallengeDailyTrackingRepository challengeDailyTrackingRepository;

  DeleteChallengeDailyTrackingUsecase(this.challengeDailyTrackingRepository);

  Future<Either<DomainError, void>> call({
    required String challengeDailyTrackingId,
  }) async {
    return await challengeDailyTrackingRepository.deleteChallengeDailyTracking(
      challengeDailyTrackingId: challengeDailyTrackingId,
    );
  }
}
