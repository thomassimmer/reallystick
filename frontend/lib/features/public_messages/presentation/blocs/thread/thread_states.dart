import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class ThreadState extends Equatable {
  final Message? message;

  const ThreadState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ThreadLoading extends ThreadState {
  const ThreadLoading({
    super.message,
  });
}

class ThreadFailed extends ThreadState {
  const ThreadFailed({
    super.message,
  });
}

class ThreadLoaded extends ThreadState {
  final List<PublicMessage> replies;
  final String? threadId;

  const ThreadLoaded({
    super.message,
    required this.replies,
    required this.threadId,
  });

  @override
  List<Object?> get props => [
        message,
        replies,
        threadId,
      ];
}
