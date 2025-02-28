// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/data/errors/data_error.dart';
import 'package:reallystick/features/public_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/public_messages/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_like_repository.dart';

class PublicMessageLikeRepositoryImpl implements PublicMessageLikeRepository {
  final PublicMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PublicMessageLikeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, void>> createPublicMessageLike({
    required String messageId,
  }) async {
    try {
      await remoteDataSource.createPublicMessageLike(
        messageId: messageId,
      );

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
    } on PublicMessageNotFoundError {
      logger.e('PublicMessageNotFoundError occurred.');
      return Left(PublicMessageNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deletePublicMessageLike({
    required String messageId,
  }) async {
    try {
      await remoteDataSource.deletePublicMessageLike(messageId);

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
    } on PublicMessageReportNotFoundError {
      logger.e('PublicMessageReportNotFoundError occurred.');
      return Left(PublicMessageReportNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
