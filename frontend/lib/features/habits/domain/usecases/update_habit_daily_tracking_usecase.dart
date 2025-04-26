import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class UpdateHabitDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  UpdateHabitDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, HabitDailyTracking>> call({
    required String habitDailyTrackingId,
    required DateTime datetime,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  }) async {
    return await habitDailyTrackingRepository.updateHabitDailyTracking(
      habitDailyTrackingId: habitDailyTrackingId,
      datetime: datetime,
      quantityPerSet: quantityPerSet,
      quantityOfSet: quantityOfSet,
      unitId: unitId,
      weight: weight,
      weightUnitId: weightUnitId,
    );
  }
}
