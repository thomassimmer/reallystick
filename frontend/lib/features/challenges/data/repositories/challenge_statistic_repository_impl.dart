// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';
import 'package:reallystick/features/challenges/domain/repositories/challenge_statistic_repository.dart';

class ChallengeStatisticRepositoryImpl implements ChallengeStatisticRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final logger = Logger();

  ChallengeStatisticRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<ChallengeStatistic>>>
      getChallengeStatistics() async {
    try {
      final challengeStatisticDataModels =
          await remoteDataSource.getChallengeStatistics();

      return Right(challengeStatisticDataModels
          .map((challengeStatiticDataModel) =>
              challengeStatiticDataModel.toDomain())
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
}
