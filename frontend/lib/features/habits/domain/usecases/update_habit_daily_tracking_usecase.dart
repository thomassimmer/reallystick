import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class UpdateHabitDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  UpdateHabitDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, HabitDailyTracking>> call({
    required String habitDailyTrackingId,
    required DateTime day,
    required Duration? duration,
    required int? quantityPerSet,
    required int? quantityOfSet,
    required String? unit,
    required bool reset,
  }) async {
    return await habitDailyTrackingRepository.updateHabitDailyTracking(
      habitDailyTrackingId: habitDailyTrackingId,
      day: day,
      duration: duration,
      quantityPerSet: quantityPerSet,
      quantityOfSet: quantityOfSet,
      unit: unit,
      reset: reset,
    );
  }
}
