// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class PublicMessageRepository {
  Future<Either<DomainError, List<PublicMessage>>> getPublicMessages({
    required String? habitId,
    required String? challengeId,
  });
  Future<Either<DomainError, List<PublicMessage>>> getMessageParents({
    required String messageId,
  });
  Future<Either<DomainError, List<PublicMessage>>> getReplies({
    required String messageId,
  });
  Future<Either<DomainError, PublicMessage>> getMessage({
    required String messageId,
  });
  Future<Either<DomainError, List<PublicMessage>>> getLikedMessages();
  Future<Either<DomainError, List<PublicMessage>>> getWrittenMessages();
  Future<Either<DomainError, PublicMessage>> createPublicMessage({
    required String? habitId,
    required String? challengeId,
    required String content,
    required String? repliesTo,
    required String? threadId,
  });
  Future<Either<DomainError, void>> deletePublicMessage({
    required String messageId,
    required bool deletedByAdmin,
  });
  Future<Either<DomainError, PublicMessage>> updatePublicMessage({
    required String messageId,
    required String content,
  });
}
