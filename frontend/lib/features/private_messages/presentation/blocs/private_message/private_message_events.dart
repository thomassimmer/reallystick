import 'package:equatable/equatable.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

abstract class PrivateMessageEvent extends Equatable {
  const PrivateMessageEvent();

  @override
  List<Object?> get props => [];
}

class InitializePrivateMessagesEvent extends PrivateMessageEvent {
  final String discussionId;

  const InitializePrivateMessagesEvent({required this.discussionId});

  @override
  List<Object?> get props => [discussionId];
}

class PrivateMessageReceivedEvent extends PrivateMessageEvent {
  final PrivateMessage message;

  const PrivateMessageReceivedEvent({
    required this.message,
  });
}

class AddNewMessageEvent extends PrivateMessageEvent {
  final String discussionId;
  final String content;
  final String creatorPublicKey;
  final String recipientPublicKey;

  const AddNewMessageEvent({
    required this.discussionId,
    required this.content,
    required this.creatorPublicKey,
    required this.recipientPublicKey,
  });
}

class UpdateMessageEvent extends PrivateMessageEvent {
  final String discussionId;
  final String messageId;
  final String content;
  final String creatorEncryptedSessionKey;

  const UpdateMessageEvent({
    required this.discussionId,
    required this.messageId,
    required this.content,
    required this.creatorEncryptedSessionKey,
  });
}

class DeleteMessageEvent extends PrivateMessageEvent {
  final String discussionId;
  final String messageId;

  const DeleteMessageEvent({
    required this.discussionId,
    required this.messageId,
  });
}

class MarkPrivateMessageAsSeenEvent extends PrivateMessageEvent {
  final String discussionId;
  final String messageId;

  const MarkPrivateMessageAsSeenEvent({
    required this.discussionId,
    required this.messageId,
  });
}
