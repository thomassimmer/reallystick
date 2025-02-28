import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';

abstract class PrivateDiscussionState extends Equatable {
  final Message? message;

  const PrivateDiscussionState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class PrivateDiscussionLoading extends PrivateDiscussionState {
  const PrivateDiscussionLoading({
    super.message,
  });
}

class PrivateDiscussionFailed extends PrivateDiscussionState {
  const PrivateDiscussionFailed({
    super.message,
  });
}

class PrivateDiscussionLoaded extends PrivateDiscussionState {
  final Map<String, PrivateDiscussion> discussions;

  const PrivateDiscussionLoaded({
    super.message,
    required this.discussions,
  });

  @override
  List<Object?> get props => [
        message,
        discussions,
      ];
}
