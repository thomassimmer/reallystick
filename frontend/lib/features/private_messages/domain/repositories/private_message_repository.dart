// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

abstract class PrivateMessageRepository {
  Future<Either<DomainError, PrivateMessage>> createPrivateMessage({
    required String discussionId,
    required String content,
    required String creatorEncryptedSessionKey,
    required String recipientEncryptedSessionKey,
  });
  Future<Either<DomainError, void>> deletePrivateMessage({
    required String messageId,
  });
  Future<Either<DomainError, List<PrivateMessage>>>
      getPrivateMessagesOfDiscussion({
    required String discussionId,
    required DateTime? beforeDate,
  });
  Future<Either<DomainError, PrivateMessage>> markPrivateMessageAsSeen({
    required String privateMessageId,
  });
  Future<Either<DomainError, PrivateMessage>> updatePrivateMessage({
    required String messageId,
    required String content,
  });
}
