import 'package:equatable/equatable.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';

class PublicMessageReportDataModel extends Equatable {
  final String id;
  final String messageId;
  final String reporter;
  final String reason;
  final DateTime createdAt;

  const PublicMessageReportDataModel({
    required this.id,
    required this.messageId,
    required this.reporter,
    required this.reason,
    required this.createdAt,
  });

  factory PublicMessageReportDataModel.fromJson(
      Map<String, dynamic> jsonObject) {
    return PublicMessageReportDataModel(
      id: jsonObject['id'] as String,
      messageId: jsonObject['message_id'] as String,
      reporter: jsonObject['reporter'] as String,
      reason: jsonObject['reason'] as String,
      createdAt: DateTime.parse(jsonObject['created_at'] as String),
    );
  }

  PublicMessageReport toDomain() => PublicMessageReport(
        id: id,
        messageId: messageId,
        reporter: reporter,
        reason: reason,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        messageId,
        reporter,
        reason,
        createdAt,
      ];
}
