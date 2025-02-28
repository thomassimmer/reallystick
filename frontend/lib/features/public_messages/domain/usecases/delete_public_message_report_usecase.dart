import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_report_repository.dart';

class DeletePublicMessageReportUsecase {
  final PublicMessageReportRepository publicMessageReportRepository;

  DeletePublicMessageReportUsecase(this.publicMessageReportRepository);

  Future<Either<DomainError, void>> call({
    required String messageReportId,
  }) async {
    return await publicMessageReportRepository.deletePublicMessageReport(
      messageReportId: messageReportId,
    );
  }
}
