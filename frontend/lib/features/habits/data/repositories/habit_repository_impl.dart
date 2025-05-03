// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/models/requests/habit.dart';
import 'package:reallystick/features/habits/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitRemoteDataSource remoteDataSource;
  final logger = Logger();

  HabitRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<Habit>>> getHabits() async {
    try {
      final habitDataModels = await remoteDataSource.getHabits();

      return Right(habitDataModels
          .map((habitDataModel) => habitDataModel.toDomain())
          .toList());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Habit>> createHabit({
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required HashSet<String> unitIds,
  }) async {
    try {
      final habitDataModel =
          await remoteDataSource.createHabit(HabitCreateRequestModel(
        name: name,
        description: description,
        categoryId: categoryId,
        icon: icon,
        unitIds: unitIds,
      ));

      return Right(habitDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on HabitCategoryNotFoundError {
      logger.e('HabitCategoryNotFoundError occurred.');
      return Left(HabitCategoryNotFoundDomainError());
    } on HabitDescriptionWrongSizeError {
      logger.e('HabitDescriptionWrongSizeError occured.');
      return Left(HabitDescriptionWrongSize());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Habit>> updateHabit({
    required String habitId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
  }) async {
    try {
      final habitDataModel = await remoteDataSource.updateHabit(
        habitId,
        HabitUpdateRequestModel(
          name: name,
          description: description,
          categoryId: categoryId,
          icon: icon,
          reviewed: reviewed,
          unitIds: unitIds,
        ),
      );

      return Right(habitDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on HabitCategoryNotFoundError {
      logger.e('HabitCategoryNotFoundError occurred.');
      return Left(HabitCategoryNotFoundDomainError());
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } on HabitDescriptionWrongSizeError {
      logger.e('HabitDescriptionWrongSizeError occured.');
      return Left(HabitDescriptionWrongSize());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteHabit({
    required String habitId,
  }) async {
    try {
      await remoteDataSource.deleteHabit(habitId);

      return Right(null);
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on HabitCategoryNotFoundError {
      logger.e('HabitCategoryNotFoundError occurred.');
      return Left(HabitCategoryNotFoundDomainError());
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Habit>> mergeHabits({
    required String habitToDeleteId,
    required String habitToMergeOnId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String categoryId,
    required String icon,
    required bool reviewed,
    required HashSet<String> unitIds,
  }) async {
    try {
      final habitDataModel = await remoteDataSource.mergeHabits(
        habitToDeleteId,
        habitToMergeOnId,
        HabitUpdateRequestModel(
          name: name,
          description: description,
          categoryId: categoryId,
          icon: icon,
          reviewed: reviewed,
          unitIds: unitIds,
        ),
      );

      return Right(habitDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on HabitCategoryNotFoundError {
      logger.e('HabitCategoryNotFoundError occurred.');
      return Left(HabitCategoryNotFoundDomainError());
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } on HabitsNotMergedError {
      logger.e('HabitsNotMergedError occurred.');
      return Left(HabitsNotMergedDomainError());
    } on HabitDescriptionWrongSizeError {
      logger.e('HabitDescriptionWrongSizeError occured.');
      return Left(HabitDescriptionWrongSize());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
