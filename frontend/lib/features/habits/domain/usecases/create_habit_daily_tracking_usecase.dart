import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class CreateHabitDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  CreateHabitDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, HabitDailyTracking>> call({
    required String habitId,
    required DateTime datetime,
    required int quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  }) async {
    return await habitDailyTrackingRepository.createHabitDailyTracking(
      habitId: habitId,
      datetime: datetime,
      quantityPerSet: quantityPerSet,
      quantityOfSet: quantityOfSet,
      unitId: unitId,
      weight: weight,
      weightUnitId: weightUnitId,
    );
  }
}
