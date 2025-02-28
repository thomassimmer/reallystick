// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/users/data/models/requests/user_public_data.dart';
import 'package:reallystick/features/users/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';
import 'package:reallystick/features/users/domain/repositories/user_public_data_repository.dart';

class UserPublicDataRepositoryImpl implements UserPublicDataRepository {
  final UserPublicDataRemoteDataSource remoteDataSource;
  final logger = Logger();

  UserPublicDataRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<UserPublicData>>> getUserPublicDataById({
    required List<String> userIds,
  }) async {
    try {
      final userPublicDataModels = await remoteDataSource.getUserPublicDataById(
        GetUserPublicDataByIdRequestModel(userIds: userIds),
      );

      return Right(userPublicDataModels
          .map((userPublicDataModel) => userPublicDataModel.toDomain())
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
  Future<Either<DomainError, UserPublicData?>> getUserPublicDataByUsername({
    required String username,
  }) async {
    try {
      final userPublicDataModel =
          await remoteDataSource.getUserPublicDataByUsername(
        GetUserPublicDataByUsernameRequestModel(username: username),
      );

      return Right(userPublicDataModel?.toDomain());
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
