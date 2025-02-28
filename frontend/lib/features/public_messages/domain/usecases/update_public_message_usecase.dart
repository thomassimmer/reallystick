import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class UpdatePublicMessageUsecase {
  final PublicMessageRepository publicMessageRepository;

  UpdatePublicMessageUsecase(this.publicMessageRepository);

  Future<Either<DomainError, PublicMessage>> call({
    required String messageId,
    required String content,
  }) async {
    return await publicMessageRepository.updatePublicMessage(
      messageId: messageId,
      content: content,
    );
  }
}
