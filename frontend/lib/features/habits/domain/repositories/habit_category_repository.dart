// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';

abstract class HabitCategoryRepository {
  Future<Either<DomainError, List<HabitCategory>>> getHabitCategories();
  Future<Either<DomainError, HabitCategory>> createHabitCategory({
    required Map<String, String> name,
    required String icon,
  });
  Future<Either<DomainError, HabitCategory>> updateHabitCategory({
    required String habitCategoryId,
    required Map<String, String> name,
    required String icon,
  });
  Future<Either<DomainError, void>> deleteHabitCategory({
    required String habitCategoryId,
  });
}
