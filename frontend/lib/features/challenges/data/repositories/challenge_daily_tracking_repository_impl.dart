// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/data/models/requests/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_daily_tracking_repository.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';

class ChallengeDailyTrackingRepositoryImpl
    implements ChallengeDailyTrackingRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final logger = Logger();

  ChallengeDailyTrackingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      getChallengeDailyTrackings({required String challengeId}) async {
    try {
      final challengeDailyTrackingDataModels =
          await remoteDataSource.getChallengeDailyTrackings(challengeId);

      return Right(challengeDailyTrackingDataModels
          .map((challengeDailyTrackingDataModel) =>
              challengeDailyTrackingDataModel.toDomain())
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
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      getChallengesDailyTrackings({required List<String> challengeIds}) async {
    try {
      final challengeDailyTrackingDataModels = await remoteDataSource
          .getChallengesDailyTrackings(ChallengeDailyTrackingsGetRequestModel(
              challengeIds: challengeIds));

      return Right(challengeDailyTrackingDataModels
          .map((challengeDailyTrackingDataModel) =>
              challengeDailyTrackingDataModel.toDomain())
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
  Future<Either<DomainError, List<ChallengeDailyTracking>>>
      createChallengeDailyTracking({
    required String challengeId,
    required String habitId,
    required int dayOfProgram,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
    required int repeat,
    required String? note,
  }) async {
    try {
      final challengeDailyTrackingDataModels =
          await remoteDataSource.createChallengeDailyTracking(
        ChallengeDailyTrackingCreateRequestModel(
          challengeId: challengeId,
          habitId: habitId,
          dayOfProgram: dayOfProgram,
          quantityPerSet: quantityPerSet,
          quantityOfSet: quantityOfSet,
          unitId: unitId,
          weight: weight,
          weightUnitId: weightUnitId,
          repeat: repeat,
          note: note,
        ),
      );

      return Right(
        challengeDailyTrackingDataModels
            .map((challengeDailyTrackingDataModel) =>
                challengeDailyTrackingDataModel.toDomain())
            .toList(),
      );
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
    } on ChallengeNotFoundError {
      logger.e('ChallengeNotFoundError occurred.');
      return Left(ChallengeNotFoundDomainError());
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } on UnitNotFoundError {
      logger.e('UnitNotFoundError occured.');
      return Left(UnitNotFoundDomainError());
    } on ChallengeDailyTrackingNoteTooLongError {
      logger.e('ChallengeDailyTrackingNoteTooLongError occured');
      return Left(ChallengeDailyTrackingNoteTooLong());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, ChallengeDailyTracking>>
      updateChallengeDailyTracking({
    required String challengeDailyTrackingId,
    required String habitId,
    required int dayOfProgram,
    required double quantityPerSet,
    required int quantityOfSet,
    required String unitId,
    required int weight,
    required String weightUnitId,
    required String? note,
  }) async {
    try {
      final challengeDailyTrackingDataModel =
          await remoteDataSource.updateChallengeDailyTracking(
        challengeDailyTrackingId,
        ChallengeDailyTrackingUpdateRequestModel(
          habitId: habitId,
          dayOfProgram: dayOfProgram,
          quantityPerSet: quantityPerSet,
          quantityOfSet: quantityOfSet,
          unitId: unitId,
          weight: weight,
          weightUnitId: weightUnitId,
          note: note,
        ),
      );

      return Right(challengeDailyTrackingDataModel.toDomain());
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
    } on ChallengeDailyTrackingNotFoundError {
      logger.e('ChallengeDailyTrackingNotFoundError occurred.');
      return Left(ChallengeDailyTrackingNotFoundDomainError());
    } on HabitNotFoundError {
      logger.e('HabitNotFoundError occurred.');
      return Left(HabitNotFoundDomainError());
    } on UnitNotFoundError {
      logger.e('UnitNotFoundError occured.');
      return Left(UnitNotFoundDomainError());
    } on ChallengeDailyTrackingNoteTooLongError {
      logger.e('ChallengeDailyTrackingNoteTooLongError occured');
      return Left(ChallengeDailyTrackingNoteTooLong());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteChallengeDailyTracking({
    required String challengeDailyTrackingId,
  }) async {
    try {
      await remoteDataSource
          .deleteChallengeDailyTracking(challengeDailyTrackingId);

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
    } on ChallengeDailyTrackingNotFoundError {
      logger.e('ChallengeDailyTrackingNotFoundError occurred.');
      return Left(ChallengeDailyTrackingNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
