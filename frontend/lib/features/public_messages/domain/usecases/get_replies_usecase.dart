import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class GetRepliesUsecase {
  final PublicMessageRepository publicMessageRepository;

  GetRepliesUsecase(this.publicMessageRepository);

  Future<Either<DomainError, List<PublicMessage>>> call({
    required String messageId,
  }) async {
    return await publicMessageRepository.getReplies(
      messageId: messageId,
    );
  }
}
