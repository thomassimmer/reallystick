import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

abstract class PrivateMessageState extends Equatable {
  final Message? message;

  const PrivateMessageState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class PrivateMessagesLoading extends PrivateMessageState {
  const PrivateMessagesLoading({
    super.message,
  });
}

class PrivateMessagesFailed extends PrivateMessageState {
  const PrivateMessagesFailed({
    super.message,
  });
}

class PrivateMessagesLoaded extends PrivateMessageState {
  final String discussionId;
  final Map<String, Map<String, PrivateMessage>> messagesByDiscussion;
  final PrivateMessage? lastMessageReceived;

  const PrivateMessagesLoaded({
    super.message,
    required this.discussionId,
    required this.messagesByDiscussion,
    required this.lastMessageReceived,
  });

  @override
  List<Object?> get props => [
        message,
        messagesByDiscussion,
        lastMessageReceived,
      ];
}
