// features/auth/data/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_discussion_participation.dart';
import 'package:reallystick/features/private_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_participation_repository.dart';

class PrivateDiscussionParticipationRepositoryImpl
    implements PrivateDiscussionParticipationRepository {
  final PrivateMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PrivateDiscussionParticipationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, void>> updatePrivateDiscussionParticipation({
    required String discussionId,
    required String color,
    required bool hasBlocked,
  }) async {
    try {
      await remoteDataSource.updatePrivateDiscussionParticipation(
        discussionId: discussionId,
        requestModel: PrivateDiscussionParticipationUpdateRequestModel(
          color: color,
          hasBlocked: hasBlocked,
        ),
      );

      return const Right(null);
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
