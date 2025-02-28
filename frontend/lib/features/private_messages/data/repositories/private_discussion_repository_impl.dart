// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_discussion.dart';
import 'package:reallystick/features/private_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_repository.dart';

class PrivateDiscussionRepositoryImpl implements PrivateDiscussionRepository {
  final PrivateMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PrivateDiscussionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, PrivateDiscussion>> createPrivateDiscussion({
    required String recipientId,
    required String color,
  }) async {
    try {
      final discussionDataModel =
          await remoteDataSource.createPrivateDiscussion(
        PrivateDiscussionCreateRequestModel(
          recipient: recipientId,
          color: color,
        ),
      );

      return Right(discussionDataModel.toDomain());
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
  Future<Either<DomainError, List<PrivateDiscussion>>>
      getPrivateDiscussions() async {
    try {
      final discussionsDataModel =
          await remoteDataSource.getPrivateDiscussions();

      return Right(discussionsDataModel.map((e) => e.toDomain()).toList());
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
}
