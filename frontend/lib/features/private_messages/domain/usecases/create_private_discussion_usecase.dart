import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_repository.dart';

class CreatePrivateDiscussionUsecase {
  final PrivateDiscussionRepository privateDiscussionRepository;

  CreatePrivateDiscussionUsecase(this.privateDiscussionRepository);

  Future<Either<DomainError, PrivateDiscussion>> call({
    required String recipientId,
    required String color,
  }) async {
    return await privateDiscussionRepository.createPrivateDiscussion(
      recipientId: recipientId,
      color: color,
    );
  }
}
