import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';

class CreateChallengeDailyTrackingUsecase {
  final ChallengeDailyTrackingRepository challengeDailyTrackingRepository;

  CreateChallengeDailyTrackingUsecase(this.challengeDailyTrackingRepository);

  Future<Either<DomainError, ChallengeDailyTracking>> call({
    required String challengeId,
    required String habitId,
    required int dayOfProgram,
    required int quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  }) async {
    return await challengeDailyTrackingRepository.createChallengeDailyTracking(
      challengeId: challengeId,
      habitId: habitId,
      dayOfProgram: dayOfProgram,
      quantityPerSet: quantityPerSet,
      quantityOfSet: quantityOfSet,
      unitId: unitId,
      weight: weight,
      weightUnitId: weightUnitId,
    );
  }
}
