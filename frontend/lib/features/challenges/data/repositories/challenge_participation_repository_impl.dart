// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/data/models/requests/challenge_participation.dart';
import 'package:reallystick/features/challenges/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_participation_repository.dart';

class ChallengeParticipationRepositoryImpl
    implements ChallengeParticipationRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final logger = Logger();

  ChallengeParticipationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<ChallengeParticipation>>>
      getChallengeParticipations() async {
    try {
      final challengeParticipationDataModels =
          await remoteDataSource.getChallengeParticipations();

      return Right(challengeParticipationDataModels
          .map((challengeParticipationDataModel) =>
              challengeParticipationDataModel.toDomain())
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
  Future<Either<DomainError, ChallengeParticipation>>
      createChallengeParticipation({
    required String challengeId,
    required String color,
    required DateTime startDate,
  }) async {
    try {
      final challengeParticipationDataModel =
          await remoteDataSource.createChallengeParticipation(
              ChallengeParticipationCreateRequestModel(
        challengeId: challengeId,
        color: color,
        startDate: startDate,
      ));

      return Right(challengeParticipationDataModel.toDomain());
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
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, ChallengeParticipation>>
      updateChallengeParticipation({
    required String challengeParticipationId,
    required String color,
    required DateTime startDate,
    required bool notificationsReminderEnabled,
    required String? reminderTime,
    required String? reminderBody,
    required bool finished,
  }) async {
    try {
      final challengeParticipationDataModel =
          await remoteDataSource.updateChallengeParticipation(
        challengeParticipationId,
        ChallengeParticipationUpdateRequestModel(
          color: color,
          startDate: startDate,
          notificationsReminderEnabled: notificationsReminderEnabled,
          reminderTime: reminderTime,
          reminderBody: reminderBody,
          finished: finished,
        ),
      );

      return Right(challengeParticipationDataModel.toDomain());
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
    } on ChallengeParticipationNotFoundError {
      logger.e('ChallengeParticipationNotFoundError occurred.');
      return Left(ChallengeParticipationNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deleteChallengeParticipation({
    required String challengeParticipationId,
  }) async {
    try {
      await remoteDataSource
          .deleteChallengeParticipation(challengeParticipationId);

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
    } on ChallengeParticipationNotFoundError {
      logger.e('ChallengeParticipationNotFoundError occurred.');
      return Left(ChallengeParticipationNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
