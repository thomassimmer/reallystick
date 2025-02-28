import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_message_repository.dart';

class GetPrivateMessagesOfDiscussionUsecase {
  final PrivateMessageRepository privateMessageRepository;

  GetPrivateMessagesOfDiscussionUsecase(this.privateMessageRepository);

  Future<Either<DomainError, List<PrivateMessage>>> call({
    required String discussionId,
  }) async {
    return await privateMessageRepository.getPrivateMessagesOfDiscussion(
      discussionId: discussionId,
    );
  }
}