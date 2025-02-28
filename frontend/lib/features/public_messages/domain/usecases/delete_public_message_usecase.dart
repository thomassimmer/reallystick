import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class DeletePublicMessageUsecase {
  final PublicMessageRepository challengeRepository;

  DeletePublicMessageUsecase(this.challengeRepository);

  Future<Either<DomainError, void>> call({
    required String messageId,
    required bool deletedByAdmin,
  }) async {
    return await challengeRepository.deletePublicMessage(
      messageId: messageId,
      deletedByAdmin: deletedByAdmin,
    );
  }
}
