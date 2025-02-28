import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_report_repository.dart';

class GetUserMessageReportsUsecase {
  final PublicMessageReportRepository publicMessageReportRepository;

  GetUserMessageReportsUsecase(this.publicMessageReportRepository);

  Future<Either<DomainError, (List<PublicMessageReport>, List<PublicMessage>)>>
      call() async {
    return await publicMessageReportRepository.getUserMessageReports();
  }
}
