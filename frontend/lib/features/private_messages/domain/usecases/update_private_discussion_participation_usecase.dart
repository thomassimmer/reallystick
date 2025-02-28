import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_participation_repository.dart';

class UpdatePrivateDiscussionParticipationUsecase {
  final PrivateDiscussionParticipationRepository
      privateDiscussionParticipationRepository;

  UpdatePrivateDiscussionParticipationUsecase(
    this.privateDiscussionParticipationRepository,
  );

  Future<Either<DomainError, void>> call({
    required String discussionId,
    required String color,
    required bool hasBlocked,
  }) async {
    return await privateDiscussionParticipationRepository
        .updatePrivateDiscussionParticipation(
      discussionId: discussionId,
      color: color,
      hasBlocked: hasBlocked,
    );
  }
}
