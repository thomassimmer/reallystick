import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';

class PrivateDiscussionState extends Equatable {
  final Message? message;
  final Map<String, PrivateDiscussion> discussions;

  const PrivateDiscussionState({
    this.message,
    required this.discussions,
  });

  @override
  List<Object?> get props => [
        message,
        discussions,
      ];
}
