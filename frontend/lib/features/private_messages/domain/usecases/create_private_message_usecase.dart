import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';

class CreatePrivateMessageUsecase {
  final PrivateMessageRepository privateMessageRepository;

  CreatePrivateMessageUsecase(this.privateMessageRepository);

  Future<Either<DomainError, PrivateMessage>> call({
    required String discussionId,
    required String content,
    required String creatorEncryptedSessionKey,
    required String recipientEncryptedSessionKey,
  }) async {
    return await privateMessageRepository.createPrivateMessage(
      discussionId: discussionId,
      content: content,
      creatorEncryptedSessionKey: creatorEncryptedSessionKey,
      recipientEncryptedSessionKey: recipientEncryptedSessionKey,
    );
  }
}