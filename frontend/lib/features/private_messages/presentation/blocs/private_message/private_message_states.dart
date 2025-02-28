import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';

class PrivateMessageState extends Equatable {
  final Message? message;
  final String discussionId;
  final Map<String, Map<String, PrivateMessage>> messagesByDiscussion;
  final PrivateMessageReceivedEvent? lastPrivateMessageReceivedEvent;

  const PrivateMessageState({
    this.message,
    required this.discussionId,
    required this.messagesByDiscussion,
    required this.lastPrivateMessageReceivedEvent,
  });

  @override
  List<Object?> get props => [
        message,
        discussionId,
        messagesByDiscussion,
        lastPrivateMessageReceivedEvent,
      ];
}
