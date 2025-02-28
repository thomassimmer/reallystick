import 'package:equatable/equatable.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';

class PrivateMessageDataModel extends Equatable {
  final String id;
  final String discussionId;
  final String creator;
  final DateTime createdAt;
  final DateTime? updateAt;
  final String content;
  final String creatorEncryptedSessionKey;
  final String recipientEncryptedSessionKey;
  final bool deleted;
  final bool seen;

  const PrivateMessageDataModel({
    required this.id,
    required this.discussionId,
    required this.creator,
    required this.createdAt,
    required this.updateAt,
    required this.content,
    required this.creatorEncryptedSessionKey,
    required this.recipientEncryptedSessionKey,
    required this.deleted,
    required this.seen,
  });

  factory PrivateMessageDataModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageDataModel(
      id: json['id'] as String,
      discussionId: json['discussion_id'] as String,
      creator: json['creator'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updateAt: json['updated_at'] is String
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      content: json['content'] as String,
      creatorEncryptedSessionKey:
          json['creator_encrypted_session_key'] as String,
      recipientEncryptedSessionKey:
          json['recipient_encrypted_session_key'] as String,
      deleted: json['deleted'] as bool,
      seen: json['seen'] as bool,
    );
  }

  PrivateMessage toDomain() => PrivateMessage(
        id: id,
        discussionId: discussionId,
        creator: creator,
        createdAt: createdAt,
        updateAt: updateAt,
        content: content,
        creatorEncryptedSessionKey: creatorEncryptedSessionKey,
        recipientEncryptedSessionKey: recipientEncryptedSessionKey,
        deleted: deleted,
        seen: seen,
      );

  @override
  List<Object?> get props => [
        id,
        discussionId,
        creator,
        createdAt,
        updateAt,
        content,
        creatorEncryptedSessionKey,
        recipientEncryptedSessionKey,
        deleted,
        seen,
      ];
}
