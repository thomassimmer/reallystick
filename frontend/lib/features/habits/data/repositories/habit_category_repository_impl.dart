// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_category.dart';
import 'package:reallystick/features/habits/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_category_repository.dart';

class HabitCategoryRepositoryImpl implements HabitCategoryRepository {
  final HabitRemoteDataSource remoteDataSource;
  final logger = Logger();

  HabitCategoryRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<HabitCategory>>> getHabitCategories() async {
    try {
      final habitCategoryDataModels =
          await remoteDataSource.getHabitCategories();

      return Right(habitCategoryDataModels
          .map((habitCategoryDataModel) => habitCategoryDataModel.toDomain())
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
  Future<Either<DomainError, HabitCategory>> createHabitCategory({
    required Map<String, String> name,
    required String icon,
  }) async {
    try {
      final habitCategoryDataModel = await remoteDataSource
          .createHabitCategory(HabitCategoryCreateRequestModel(
        name: name,
        icon: icon,
      ));

      return Right(habitCategoryDataModel.toDomain());
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
  Future<Either<DomainError, HabitCategory>> updateHabitCategory({
    required String habitCategoryId,
    required Map<String, String> name,
    required String icon,
  }) async {
    try {
      final habitCategoryDataModel = await remoteDataSource.updateHabitCategory(
        habitCategoryId,
        HabitCategoryUpdateRequestModel(
          name: name,
          icon: icon,
        ),
      );

      return Right(habitCategoryDataModel.toDomain());
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
      logger.e('HabitCategoryNotFoundError occured.');
      return Left(HabitCategoryNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteHabitCategory({
    required String habitCategoryId,
  }) async {
    try {
      await remoteDataSource.deleteHabitCategory(habitCategoryId);

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
      logger.e('HabitCategoryNotFoundError occured.');
      return Left(HabitCategoryNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
