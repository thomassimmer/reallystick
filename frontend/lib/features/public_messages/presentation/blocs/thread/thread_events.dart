import 'package:equatable/equatable.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class ThreadEvent extends Equatable {
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

class InitializeThreadEvent extends ThreadEvent {
  final String threadId;

  const InitializeThreadEvent({
    required this.threadId,
  });

  @override
  List<Object?> get props => [
        threadId,
      ];
}

class AddNewThreadMessage extends ThreadEvent {
  final PublicMessage message;

  const AddNewThreadMessage({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class UpdateThreadMessage extends ThreadEvent {
  final PublicMessage message;

  const UpdateThreadMessage({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}

class DeleteThreadMessage extends ThreadEvent {
  final String messageId;
  final bool deletedByAdmin;

  const DeleteThreadMessage({
    required this.messageId,
    required this.deletedByAdmin,
  });

  @override
  List<Object?> get props => [
        messageId,
        deletedByAdmin,
      ];
}

class AddLikeOnThreadMessage extends ThreadEvent {
  final String messageId;

  const AddLikeOnThreadMessage({
    required this.messageId,
  });

  @override
  List<Object?> get props => [
        messageId,
      ];
}

class DeleteLikeOnThreadMessage extends ThreadEvent {
  final String messageId;

  const DeleteLikeOnThreadMessage({
    required this.messageId,
  });

  @override
  List<Object?> get props => [
        messageId,
      ];
}
