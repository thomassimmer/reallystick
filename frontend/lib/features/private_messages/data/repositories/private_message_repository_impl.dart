// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_message.dart';
import 'package:reallystick/features/private_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/domain/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';

class PrivateMessageRepositoryImpl implements PrivateMessageRepository {
  final PrivateMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PrivateMessageRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, PrivateMessage>> createPrivateMessage({
    required String discussionId,
    required String content,
    required String creatorEncryptedSessionKey,
    required String recipientEncryptedSessionKey,
  }) async {
    try {
      final messageDataModel = await remoteDataSource.createPrivateMessage(
        PrivateMessageCreateRequestModel(
          discussionId: discussionId,
          content: content,
          creatorEncryptedSessionKey: creatorEncryptedSessionKey,
          recipientEncryptedSessionKey: recipientEncryptedSessionKey,
        ),
      );

      return Right(messageDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } on PrivateMessageContentEmptyError {
      logger.e('PrivateMessageContentEmptyError occured');
      return Left(PrivateMessageContentEmpty());
    } on PrivateMessageContentTooLongError {
      logger.e('PrivateMessageContentTooLongError occured');
      return Left(PrivateMessageContentTooLong());
    } catch (e) {
      logger.e('Unknown error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deletePrivateMessage({
    required String messageId,
  }) async {
    try {
      await remoteDataSource.deletePrivateMessage(messageId);
      return const Right(null);
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on PrivateMessageNotFoundError {
      logger.e('PrivateMessageNotFoundError occurred.');
      return Left(PrivateMessageNotFoundDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Unknown error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, List<PrivateMessage>>>
      getPrivateMessagesOfDiscussion({
    required String discussionId,
  }) async {
    try {
      final messagesDataModels =
          await remoteDataSource.getPrivateMessagesOfDiscussion(
        discussionId,
      );

      return Right(messagesDataModels.map((m) => m.toDomain()).toList());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Unknown error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, PrivateMessage>> markPrivateMessageAsSeen({
    required String privateMessageId,
  }) async {
    try {
      final messageDataModel =
          await remoteDataSource.markPrivateMessageAsSeen(privateMessageId);

      return Right(messageDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on PrivateMessageNotFoundError {
      logger.e('PrivateMessageNotFoundError occurred.');
      return Left(PrivateMessageNotFoundDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Unknown error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, PrivateMessage>> updatePrivateMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final messageDataModel = await remoteDataSource.updatePrivateMessage(
        messageId: messageId,
        content: content,
      );

      return Right(messageDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on PrivateMessageNotFoundError {
      logger.e('PrivateMessageNotFoundError occurred.');
      return Left(PrivateMessageNotFoundDomainError());
    } on PrivateMessageContentEmptyError {
      logger.e('PrivateMessageContentEmptyError occured');
      return Left(PrivateMessageContentEmpty());
    } on PrivateMessageContentTooLongError {
      logger.e('PrivateMessageContentTooLongError occured');
      return Left(PrivateMessageContentTooLong());
    } on InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Unknown error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
