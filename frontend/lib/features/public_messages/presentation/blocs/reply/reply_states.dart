import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

abstract class ReplyState extends Equatable {
  final Message? message;

  const ReplyState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ReplyLoading extends ReplyState {
  const ReplyLoading({
    super.message,
  });
}

class ReplyFailed extends ReplyState {
  const ReplyFailed({
    super.message,
  });
}

class ReplyLoaded extends ReplyState {
  final List<PublicMessage> replies;
  final List<PublicMessage> parents;
  final PublicMessage? reply;

  const ReplyLoaded({
    super.message,
    required this.replies,
    required this.parents,
    required this.reply,
  });

  @override
  List<Object?> get props => [
        message,
        replies,
        parents,
        reply,
      ];
}
