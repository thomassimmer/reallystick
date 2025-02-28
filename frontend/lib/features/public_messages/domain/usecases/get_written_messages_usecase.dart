import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_repository.dart';

class GetWrittenMessagesUsecase {
  final PublicMessageRepository publicMessageRepository;

  GetWrittenMessagesUsecase(this.publicMessageRepository);

  Future<Either<DomainError, List<PublicMessage>>> call() async {
    return await publicMessageRepository.getWrittenMessages();
  }
}
