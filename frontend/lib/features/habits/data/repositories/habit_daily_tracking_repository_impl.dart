// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_daily_tracking_repository.dart';

class HabitDailyTrackingRepositoryImpl implements HabitDailyTrackingRepository {
  final HabitRemoteDataSource remoteDataSource;
  final logger = Logger();

  HabitDailyTrackingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<HabitDailyTracking>>>
      getHabitDailyTracking() async {
    try {
      final habitDailyTrackingDataModels =
          await remoteDataSource.getHabitDailyTracking();

      return Right(habitDailyTrackingDataModels
          .map((habitDailyTrackingDataModel) =>
              habitDailyTrackingDataModel.toDomain())
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
  Future<Either<DomainError, HabitDailyTracking>> createHabitDailyTracking({
    required String habitId,
    required DateTime datetime,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  }) async {
    try {
      final habitDailyTrackingDataModel = await remoteDataSource
          .createHabitDailyTracking(HabitDailyTrackingCreateRequestModel(
        habitId: habitId,
        datetime: datetime,
        quantityPerSet: quantityPerSet,
        quantityOfSet: quantityOfSet,
        unitId: unitId,
        weight: weight,
        weightUnitId: weightUnitId,
      ));

      return Right(habitDailyTrackingDataModel.toDomain());
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
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, HabitDailyTracking>> updateHabitDailyTracking({
    required String habitDailyTrackingId,
    required DateTime datetime,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
  }) async {
    try {
      final habitDailyTrackingDataModel =
          await remoteDataSource.updateHabitDailyTracking(
        habitDailyTrackingId,
        HabitDailyTrackingUpdateRequestModel(
          datetime: datetime,
          quantityPerSet: quantityPerSet,
          quantityOfSet: quantityOfSet,
          unitId: unitId,
          weight: weight,
          weightUnitId: weightUnitId,
        ),
      );

      return Right(habitDailyTrackingDataModel.toDomain());
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
    } on HabitDailyTrackingNotFoundError {
      logger.e('HabitDailyTrackingNotFoundError occurred.');
      return Left(HabitDailyTrackingNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteHabitDailyTracking({
    required String habitDailyTrackingId,
  }) async {
    try {
      await remoteDataSource.deleteHabitDailyTracking(habitDailyTrackingId);

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
    } on HabitDailyTrackingNotFoundError {
      logger.e('HabitDailyTrackingNotFoundError occurred.');
      return Left(HabitDailyTrackingNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
