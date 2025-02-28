import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

class PrivateDiscussion {
  String id;
  String color;
  bool hasBlocked;
  DateTime createdAt;
  PrivateMessage? lastMessage;
  String recipientId;
  int unseenMessages;

  PrivateDiscussion({
    required this.id,
    required this.color,
    required this.hasBlocked,
    required this.createdAt,
    required this.lastMessage,
    required this.recipientId,
    required this.unseenMessages,
  });

  PrivateDiscussion copyWith({
    String? id,
    String? color,
    bool? hasBlocked,
    DateTime? createdAt,
    PrivateMessage? lastMessage,
    String? recipientId,
    int? unseenMessages,
  }) {
    return PrivateDiscussion(
      id: id ?? this.id,
      color: color ?? this.color,
      hasBlocked: hasBlocked ?? this.hasBlocked,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      recipientId: recipientId ?? this.recipientId,
      unseenMessages: unseenMessages ?? this.unseenMessages,
    );
  }
}
