// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/challenges/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/domain/errors/domain_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/data/errors/data_error.dart';
import 'package:reallystick/features/public_messages/data/models/requests/public_message.dart';
import 'package:reallystick/features/public_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class PublicMessageRepositoryImpl implements PublicMessageRepository {
  final PublicMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PublicMessageRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, List<PublicMessage>>> getPublicMessages(
      {required String? challengeId, required String? habitId}) async {
    try {
      final publicMessageDataModels =
          await remoteDataSource.getPublicMessages(challengeId, habitId);

      return Right(publicMessageDataModels
          .map((publicMessageDataModel) => publicMessageDataModel.toDomain())
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
  Future<Either<DomainError, List<PublicMessage>>> getMessageParents({
    required String messageId,
  }) async {
    try {
      final publicMessageDataModels =
          await remoteDataSource.getParentMessages(messageId);

      return Right(publicMessageDataModels
          .map((publicMessageDataModel) => publicMessageDataModel.toDomain())
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
    } on PublicMessageNotFoundError {
      logger.e('PublicMessageNotFoundError occurred.');
      return Left(PublicMessageNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, List<PublicMessage>>> getReplies({
    required String messageId,
  }) async {
    try {
      final publicMessageDataModels =
          await remoteDataSource.getReplies(messageId);

      return Right(publicMessageDataModels
          .map((publicMessageDataModel) => publicMessageDataModel.toDomain())
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
    } on PublicMessageNotFoundError {
      logger.e('PublicMessageNotFoundError occurred.');
      return Left(PublicMessageNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, List<PublicMessage>>> getLikedMessages() async {
    try {
      final publicMessageDataModels = await remoteDataSource.getLikedMessages();

      return Right(publicMessageDataModels
          .map((publicMessageDataModel) => publicMessageDataModel.toDomain())
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
  Future<Either<DomainError, List<PublicMessage>>> getWrittenMessages() async {
    try {
      final publicMessageDataModels =
          await remoteDataSource.getWrittenMessages();

      return Right(publicMessageDataModels
          .map((publicMessageDataModel) => publicMessageDataModel.toDomain())
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
  Future<Either<DomainError, PublicMessage>> createPublicMessage({
    required String? habitId,
    required String? challengeId,
    required String? repliesTo,
    required String content,
    required String? threadId,
  }) async {
    try {
      final publicMessageDataModel = await remoteDataSource.createPublicMessage(
        PublicMessageCreateRequestModel(
          habitId: habitId,
          challengeId: challengeId,
          repliesTo: repliesTo,
          content: content,
          threadId: threadId,
        ),
      );

      return Right(publicMessageDataModel.toDomain());
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
    } on PublicMessageNotFoundError {
      logger.e('PublicMessageNotFoundError occurred.');
      return Left(PublicMessageNotFoundDomainError());
    } on PublicMessageContentTooLongError {
      logger.e('PublicMessageContentTooLongError occured');
      return Left(PublicMessageContentTooLong());
    } on PublicMessageContentEmptyError {
      logger.e('PublicMessageContentEmptyError occured');
      return Left(PublicMessageContentEmpty());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, PublicMessage>> updatePublicMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final publicMessageDataModel = await remoteDataSource.updatePublicMessage(
        messageId,
        PublicMessageUpdateRequestModel(content: content),
      );

      return Right(publicMessageDataModel.toDomain());
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
    } on PublicMessageContentTooLongError {
      logger.e('PublicMessageContentTooLongError occured');
      return Left(PublicMessageContentTooLong());
    } on PublicMessageContentEmptyError {
      logger.e('PublicMessageContentEmptyError occured');
      return Left(PublicMessageContentEmpty());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deletePublicMessage({
    required String messageId,
    required bool deletedByAdmin,
  }) async {
    try {
      await remoteDataSource.deletePublicMessage(
        messageId,
        deletedByAdmin,
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
  Future<Either<DomainError, PublicMessage>> getMessage({
    required String messageId,
  }) async {
    try {
      final publicMessageDataModel =
          await remoteDataSource.getMessage(messageId);

      return Right(publicMessageDataModel.toDomain());
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
}
