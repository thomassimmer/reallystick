import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';

class DeleteHabitCategoryUsecase {
  final HabitCategoryRepository habitCategoryRepository;

  DeleteHabitCategoryUsecase(this.habitCategoryRepository);

  Future<Either<DomainError, void>> call({
    required String habitCategoryId,
  }) async {
    return await habitCategoryRepository.deleteHabitCategory(
      habitCategoryId: habitCategoryId,
    );
  }
}
