import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';

abstract class PublicMessageState extends Equatable {
  final Message? message;

  const PublicMessageState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class PublicMessagesLoading extends PublicMessageState {
  const PublicMessagesLoading({
    super.message,
  });
}

class PublicMessagesFailed extends PublicMessageState {
  const PublicMessagesFailed({
    super.message,
  });
}

class PublicMessagesLoaded extends PublicMessageState {
  final String? challengeId;
  final String? habitId;
  final List<PublicMessage> threads;

  final List<PublicMessage> likedMessages;
  final List<PublicMessage> writtenMessages;
  final List<PublicMessage> userReportedMessages;
  final List<PublicMessage> allReportedMessages;
  final List<PublicMessageReport> userReports;
  final List<PublicMessageReport> allReports;

  const PublicMessagesLoaded({
    super.message,
    required this.challengeId,
    required this.habitId,
    required this.threads,
    required this.likedMessages,
    required this.writtenMessages,
    required this.userReportedMessages,
    required this.allReportedMessages,
    required this.userReports,
    required this.allReports,
  });

  @override
  List<Object?> get props => [
        message,
        challengeId,
        habitId,
        threads,
        likedMessages,
        writtenMessages,
        userReportedMessages,
        allReportedMessages,
        userReports,
        allReports,
      ];
}
