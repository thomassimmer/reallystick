// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';

abstract class PublicMessageReportRepository {
  Future<Either<DomainError, (List<PublicMessageReport>, List<PublicMessage>)>>
      getMessageReports();
  Future<Either<DomainError, (List<PublicMessageReport>, List<PublicMessage>)>>
      getUserMessageReports();
  Future<Either<DomainError, PublicMessageReport>> createPublicMessageReport({
    required String messageId,
    required String reason,
  });
  Future<Either<DomainError, void>> deletePublicMessageReport({
    required String messageReportId,
  });
}
