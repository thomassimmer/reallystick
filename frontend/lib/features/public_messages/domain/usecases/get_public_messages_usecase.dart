import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class GetPublicMessagesUsecase {
  final PublicMessageRepository publicMessageRepository;

  GetPublicMessagesUsecase(this.publicMessageRepository);

  Future<Either<DomainError, List<PublicMessage>>> call({
    required String? habitId,
    required String? challengeId,
  }) async {
    return await publicMessageRepository.getPublicMessages(
      habitId: habitId,
      challengeId: challengeId,
    );
  }
}
