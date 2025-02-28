import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class GetMessageUsecase {
  final PublicMessageRepository publicMessageRepository;

  GetMessageUsecase(this.publicMessageRepository);

  Future<Either<DomainError, PublicMessage>> call({
    required String messageId,
  }) async {
    return await publicMessageRepository.getMessage(
      messageId: messageId,
    );
  }
}
