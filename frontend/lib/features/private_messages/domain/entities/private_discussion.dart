import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

class PrivateDiscussion {
  String id;
  String color;
  bool hasBlocked;
  DateTime createdAt;
  PrivateMessage? lastMessage;
  String recipientId;

  PrivateDiscussion({
    required this.id,
    required this.color,
    required this.hasBlocked,
    required this.createdAt,
    required this.lastMessage,
    required this.recipientId,
  });
}
