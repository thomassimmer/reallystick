// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_participation.dart';
import 'package:reallystick/features/habits/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/habits/domain/entities/habit_participation.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/repositories/habit_participation_repository.dart';

class HabitParticipationRepositoryImpl implements HabitParticipationRepository {
  final HabitRemoteDataSource remoteDataSource;
  final logger = Logger();

  HabitParticipationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<HabitParticipation>>>
      getHabitParticipations() async {
    try {
      final habitParticipationDataModels =
          await remoteDataSource.getHabitParticipations();

      return Right(habitParticipationDataModels
          .map((habitParticipationDataModel) =>
              habitParticipationDataModel.toDomain())
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
  Future<Either<DomainError, HabitParticipation>> createHabitParticipation({
    required String habitId,
    required String color,
    required bool toGain,
  }) async {
    try {
      final habitParticipationDataModel = await remoteDataSource
          .createHabitParticipation(HabitParticipationCreateRequestModel(
        habitId: habitId,
        color: color,
        toGain: toGain,
      ));

      return Right(habitParticipationDataModel.toDomain());
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
  Future<Either<DomainError, HabitParticipation>> updateHabitParticipation({
    required String habitParticipationId,
    required String color,
    required bool toGain,
  }) async {
    try {
      final habitParticipationDataModel =
          await remoteDataSource.updateHabitParticipation(
        habitParticipationId,
        HabitParticipationUpdateRequestModel(
          color: color,
          toGain: toGain,
        ),
      );

      return Right(habitParticipationDataModel.toDomain());
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
    } on HabitParticipationNotFoundError {
      logger.e('HabitParticipationNotFoundError occurred.');
      return Left(HabitParticipationNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteHabitParticipation({
    required String habitParticipationId,
  }) async {
    try {
      await remoteDataSource.deleteHabitParticipation(habitParticipationId);

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
    } on HabitParticipationNotFoundError {
      logger.e('HabitParticipationNotFoundError occurred.');
      return Left(HabitParticipationNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
