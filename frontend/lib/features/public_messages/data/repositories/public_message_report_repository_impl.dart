// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/data/errors/data_error.dart';
import 'package:reallystick/features/public_messages/data/models/requests/public_message_report.dart';
import 'package:reallystick/features/public_messages/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';
import 'package:reallystick/features/public_messages/domain/errors/domain_error.dart';
import 'package:reallystick/features/public_messages/domain/repositories/public_message_report_repository.dart';

class PublicMessageReportRepositoryImpl
    implements PublicMessageReportRepository {
  final PublicMessageRemoteDataSource remoteDataSource;
  final logger = Logger();

  PublicMessageReportRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<DomainError, (List<PublicMessageReport>, List<PublicMessage>)>>
      getMessageReports() async {
    try {
      final (publicMessageReportDataModels, publicMessageDataModels) =
          await remoteDataSource.getMessageReports();

      return Right(
        (
          publicMessageReportDataModels
              .map((publicMessageReportDataModel) =>
                  publicMessageReportDataModel.toDomain())
              .toList(),
          publicMessageDataModels
              .map(
                  (publicMessageDataModel) => publicMessageDataModel.toDomain())
              .toList()
        ),
      );
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, (List<PublicMessageReport>, List<PublicMessage>)>>
      getUserMessageReports() async {
    try {
      final (publicMessageReportDataModels, publicMessageDataModels) =
          await remoteDataSource.getUserMessageReports();

      return Right(
        (
          publicMessageReportDataModels
              .map((publicMessageReportDataModel) =>
                  publicMessageReportDataModel.toDomain())
              .toList(),
          publicMessageDataModels
              .map(
                  (publicMessageDataModel) => publicMessageDataModel.toDomain())
              .toList()
        ),
      );
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, PublicMessageReport>> createPublicMessageReport({
    required String messageId,
    required String reason,
  }) async {
    try {
      final publicMessageReportDataModel =
          await remoteDataSource.createPublicMessageReport(
        PublicMessageReportCreateRequestModel(
          messageId: messageId,
          reason: reason,
        ),
      );

      return Right(publicMessageReportDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on PublicMessageNotFoundError {
      logger.e('PublicMessageNotFoundError occurred.');
      return Left(PublicMessageNotFoundDomainError());
    } on PublicMessageReportReasonTooLongError {
      logger.e('PublicMessageReportReasonTooLongError occured.');
      return Left(PublicMessageReportReasonTooLong());
    } on PublicMessageReportReasonEmptyError {
      logger.e('PublicMessageReportReasonEmptyError occured.');
      return Left(PublicMessageReportReasonEmpty());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, void>> deletePublicMessageReport({
    required String messageReportId,
  }) async {
    try {
      await remoteDataSource.deletePublicMessageReport(messageReportId);

      return Right(null);
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } on PublicMessageReportNotFoundError {
      logger.e('PublicMessageReportNotFoundError occurred.');
      return Left(PublicMessageReportNotFoundDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }
}
