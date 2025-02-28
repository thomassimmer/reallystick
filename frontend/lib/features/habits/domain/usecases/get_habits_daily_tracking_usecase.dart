import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class GetHabitsDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  GetHabitsDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, List<HabitDailyTracking>>> call() async {
    return await habitDailyTrackingRepository.getHabitDailyTracking();
  }
}
