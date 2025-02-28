import 'package:equatable/equatable.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class ReplyEvent extends Equatable {
  const ReplyEvent();

  @override
  List<Object?> get props => [];
}

class InitializeReplyEvent extends ReplyEvent {
  final String messageId;

  const InitializeReplyEvent({
    required this.messageId,
  });

  @override
  List<Object?> get props => [
        messageId,
      ];
}

class AddNewReplyMessage extends ReplyEvent {
  final PublicMessage message;

  const AddNewReplyMessage({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class UpdateReplyMessage extends ReplyEvent {
  final PublicMessage message;

  const UpdateReplyMessage({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class DeleteReplyMessage extends ReplyEvent {
  final String messageId;
  final bool deletedByAdmin;

  const DeleteReplyMessage({
    required this.messageId,
    required this.deletedByAdmin,
  });

  @override
  List<Object?> get props => [
        messageId,
        deletedByAdmin,
      ];
}

class AddLikeOnReplyMessage extends ReplyEvent {
  final String messageId;

  const AddLikeOnReplyMessage({
    required this.messageId,
  });

  @override
  List<Object?> get props => [
        messageId,
      ];
}

class DeleteLikeOnReplyMessage extends ReplyEvent {
  final String messageId;

  const DeleteLikeOnReplyMessage({
    required this.messageId,
  });

  @override
  List<Object?> get props => [
        messageId,
      ];
}
