import 'package:equatable/equatable.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

abstract class PrivateDiscussionEvent extends Equatable {
  const PrivateDiscussionEvent();

  @override
  List<Object?> get props => [];
}

class InitializePrivateDiscussionsEvent extends PrivateDiscussionEvent {}

class AddNewDiscussionEvent extends PrivateDiscussionEvent {
  final String recipient;
  final String content;
  final String creatorPublicKey;
  final String recipientPublicKey;

  const AddNewDiscussionEvent({
    required this.recipient,
    required this.content,
    required this.creatorPublicKey,
    required this.recipientPublicKey,
  });
}

class UpdateDiscussionParticipationEvent extends PrivateDiscussionEvent {
  final String discussionId;
  final String color;
  final bool hasBlocked;

  const UpdateDiscussionParticipationEvent({
    required this.discussionId,
    required this.color,
    required this.hasBlocked,
  });
}

class UpdateDiscussionLastMessage extends PrivateDiscussionEvent {
  final PrivateMessage message;

  const UpdateDiscussionLastMessage({
    required this.message,
  });
}
