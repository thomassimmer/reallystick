import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_like_repository.dart';

class DeletePublicMessageLikeUsecase {
  final PublicMessageLikeRepository publicMessageLikeRepository;

  DeletePublicMessageLikeUsecase(this.publicMessageLikeRepository);

  Future<Either<DomainError, void>> call({
    required String messageId,
  }) async {
    return await publicMessageLikeRepository.deletePublicMessageLike(
      messageId: messageId,
    );
  }
}
