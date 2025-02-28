import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class DeleteHabitDailyTrackingUsecase {
  final HabitDailyTrackingRepository habitDailyTrackingRepository;

  DeleteHabitDailyTrackingUsecase(this.habitDailyTrackingRepository);

  Future<Either<DomainError, void>> call({
    required String habitDailyTrackingId,
  }) async {
    return await habitDailyTrackingRepository.deleteHabitDailyTracking(
      habitDailyTrackingId: habitDailyTrackingId,
    );
  }
}
