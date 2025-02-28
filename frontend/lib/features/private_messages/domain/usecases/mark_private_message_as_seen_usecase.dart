import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';

class MarkPrivateMessageAsSeenUsecase {
  final PrivateMessageRepository privateMessageRepository;

  MarkPrivateMessageAsSeenUsecase(this.privateMessageRepository);

  Future<Either<DomainError, PrivateMessage>> call({
    required String privateMessageId,
  }) async {
    return await privateMessageRepository.markPrivateMessageAsSeen(
      privateMessageId: privateMessageId,
    );
  }
}