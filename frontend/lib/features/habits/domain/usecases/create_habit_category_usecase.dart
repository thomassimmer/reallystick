import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';

class CreateHabitCategoryUsecase {
  final HabitCategoryRepository habitCategoryRepository;

  CreateHabitCategoryUsecase(this.habitCategoryRepository);

  Future<Either<DomainError, HabitCategory>> call({
    required Map<String, String> name,
    required String icon,
  }) async {
    return await habitCategoryRepository.createHabitCategory(
      name: name,
      icon: icon,
    );
  }
}
