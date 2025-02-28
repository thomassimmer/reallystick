import 'package:equatable/equatable.dart';
import 'package:reallystick/features/private_messages/data/models/private_message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';

class PrivateDiscussionDataModel extends Equatable {
  final String id;
  final String color;
  final bool hasBlocked;
  final DateTime createdAt;
  final PrivateMessageDataModel? lastMessage;
  final String recipientId;

  const PrivateDiscussionDataModel({
    required this.id,
    required this.color,
    required this.hasBlocked,
    required this.createdAt,
    required this.lastMessage,
    required this.recipientId,
  });

  factory PrivateDiscussionDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return PrivateDiscussionDataModel(
      id: jsonObject['id'] as String,
      color: jsonObject['color'] as String,
      hasBlocked: jsonObject['has_blocked'] as bool,
      createdAt: DateTime.parse(jsonObject['created_at'] as String),
      lastMessage: jsonObject['last_message'] is Map<String, dynamic>
          ? PrivateMessageDataModel.fromJson(jsonObject['last_message'])
          : null,
      recipientId: jsonObject['recipient_id'] as String,
    );
  }

  PrivateDiscussion toDomain() => PrivateDiscussion(
        id: id,
        color: color,
        hasBlocked: hasBlocked,
        createdAt: createdAt,
        lastMessage: lastMessage?.toDomain(),
        recipientId: recipientId,
      );

  @override
  List<Object?> get props => [
        id,
        color,
        hasBlocked,
        createdAt,
        lastMessage,
        recipientId,
      ];
}
