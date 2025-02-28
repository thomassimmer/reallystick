import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class CreateHabitDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  CreateHabitDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, HabitDailyTracking>> call({
    required String habitId,
    required DateTime day,
    required Duration? duration,
    required int? quantityPerSet,
    required int? quantityOfSet,
    required String? unit,
    required bool reset,
  }) async {
    return await habitDailyTrackingRepository.createHabitDailyTracking(
      habitId: habitId,
      day: day,
      duration: duration,
      quantityPerSet: quantityPerSet,
      quantityOfSet: quantityOfSet,
      unit: unit,
      reset: reset,
    );
  }
}
