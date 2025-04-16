import 'package:equatable/equatable.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class PublicMessageEvent extends Equatable {
  const PublicMessageEvent();

  @override
  List<Object?> get props => [];
}

class PublicMessageInitializeEvent extends PublicMessageEvent {
  final String? habitId;
  final String? challengeId;

  const PublicMessageInitializeEvent({
    required this.habitId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [habitId, challengeId];
}

class CreatePublicMessageEvent extends PublicMessageEvent {
  final String? habitId;
  final String? challengeId;
  final String? repliesTo;
  final String content;
  final String? threadId;

  const CreatePublicMessageEvent({
    required this.habitId,
    required this.challengeId,
    required this.repliesTo,
    required this.content,
    required this.threadId,
  });

  @override
  List<Object?> get props => [
        habitId,
        challengeId,
        repliesTo,
        content,
        threadId,
      ];
}

class UpdatePublicMessageEvent extends PublicMessageEvent {
  final String messageId;
  final String content;

  const UpdatePublicMessageEvent({
    required this.messageId,
    required this.content,
  });

  @override
  List<Object?> get props => [messageId, content];
}

class DeletePublicMessageEvent extends PublicMessageEvent {
  final PublicMessage message;
  final bool deletedByAdmin;

  const DeletePublicMessageEvent({
    required this.message,
    required this.deletedByAdmin,
  });

  @override
  List<Object?> get props => [
        message,
        deletedByAdmin,
      ];
}

class CreatePublicMessageLikeEvent extends PublicMessageEvent {
  final PublicMessage message;

  const CreatePublicMessageLikeEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeletePublicMessageLikeEvent extends PublicMessageEvent {
  final String messageId;

  const DeletePublicMessageLikeEvent({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class DeletePublicMessageReportEvent extends PublicMessageEvent {
  final String messageReportId;

  const DeletePublicMessageReportEvent({required this.messageReportId});

  @override
  List<Object?> get props => [messageReportId];
}

class CreatePublicMessageReportEvent extends PublicMessageEvent {
  final PublicMessage message;
  final String reason;

  const CreatePublicMessageReportEvent({
    required this.message,
    required this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

class GetPublicMessagesEvent extends PublicMessageEvent {
  final String? habitId;
  final String? challengeId;

  const GetPublicMessagesEvent({
    required this.habitId,
    required this.challengeId,
  });

  @override
  List<Object?> get props => [
        habitId,
        challengeId,
      ];
}

class GetMessageReportsEvent extends PublicMessageEvent {
  const GetMessageReportsEvent();

  @override
  List<Object?> get props => [];
}

class GetUserMessageReportsEvent extends PublicMessageEvent {
  const GetUserMessageReportsEvent();

  @override
  List<Object?> get props => [];
}

class GetLikedMessagesEvent extends PublicMessageEvent {
  const GetLikedMessagesEvent();

  @override
  List<Object?> get props => [];
}

class GetWrittenMessagesEvent extends PublicMessageEvent {
  const GetWrittenMessagesEvent();

  @override
  List<Object?> get props => [];
}
