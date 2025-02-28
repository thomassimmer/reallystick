import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';

class UpdateHabitCategoryUsecase {
  final HabitCategoryRepository habitCategoryRepository;

  UpdateHabitCategoryUsecase(this.habitCategoryRepository);

  Future<Either<DomainError, HabitCategory>> call({
    required String habitCategoryId,
    required Map<String, String> name,
    required String icon,
  }) async {
    return await habitCategoryRepository.updateHabitCategory(
      habitCategoryId: habitCategoryId,
      name: name,
      icon: icon,
    );
  }
}
