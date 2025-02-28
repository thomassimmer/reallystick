import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_report_repository.dart';

class CreatePublicMessageReportUsecase {
  final PublicMessageReportRepository publicMessageReportRepository;

  CreatePublicMessageReportUsecase(this.publicMessageReportRepository);

  Future<Either<DomainError, PublicMessageReport>> call({
    required String messageId,
    required String reason,
  }) async {
    return await publicMessageReportRepository.createPublicMessageReport(
      messageId: messageId,
      reason: reason,
    );
  }
}
