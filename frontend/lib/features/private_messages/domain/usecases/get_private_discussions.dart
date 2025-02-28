import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/repositories/private_discussion_repository.dart';

class GetPrivateDiscussionsUsecase {
  final PrivateDiscussionRepository privateDiscussionRepository;

  GetPrivateDiscussionsUsecase(this.privateDiscussionRepository);

  Future<Either<DomainError, List<PrivateDiscussion>>> call() async {
    return await privateDiscussionRepository.getPrivateDiscussions();
  }
}