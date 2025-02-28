import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';

class GetHabitCategoriesUseCase {
  final HabitCategoryRepository habitCategoryRepository;

  GetHabitCategoriesUseCase(this.habitCategoryRepository);

  Future<Either<DomainError, List<HabitCategory>>> call() async {
    return await habitCategoryRepository.getHabitCategories();
  }
}
