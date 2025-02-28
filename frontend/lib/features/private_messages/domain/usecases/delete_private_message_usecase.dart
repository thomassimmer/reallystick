import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';

class DeletePrivateMessageUsecase {
  final PrivateMessageRepository privateMessageRepository;

  DeletePrivateMessageUsecase(this.privateMessageRepository);

  Future<Either<DomainError, void>> call({
    required String messageId,
  }) async {
    return await privateMessageRepository.deletePrivateMessage(messageId: messageId);
  }
}