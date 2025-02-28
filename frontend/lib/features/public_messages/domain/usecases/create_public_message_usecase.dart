import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class CreatePublicMessageUsecase {
  final PublicMessageRepository publicMessageRepository;

  CreatePublicMessageUsecase(this.publicMessageRepository);

  Future<Either<DomainError, PublicMessage>> call({
    required String? habitId,
    required String? challengeId,
    required String content,
    required String? repliesTo,
    required String? threadId,
  }) async {
    return await publicMessageRepository.createPublicMessage(
      habitId: habitId,
      challengeId: challengeId,
      content: content,
      repliesTo: repliesTo,
      threadId: threadId,
    );
  }
}
