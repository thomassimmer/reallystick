import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_statistic.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_statistic_repository.dart';

class GetHabitStatisticsUsecase {
  final HabitStatisticRepository habitStatisticRepository;

  GetHabitStatisticsUsecase(this.habitStatisticRepository);

  Future<Either<DomainError, List<HabitStatistic>>> call() async {
    return await habitStatisticRepository.getHabitStatistics();
  }
}
