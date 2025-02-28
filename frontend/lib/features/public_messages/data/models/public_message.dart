import 'package:equatable/equatable.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';

class PublicMessageDataModel extends Equatable {
  final String id;
  final String? habitId;
  final String? challengeId;
  final String creator;
  final String threadId;
  final String? repliesTo;
  final DateTime createdAt;
  final DateTime? updateAt;
  final String content;
  final int likeCount;
  final int replyCount;
  final bool deletedByCreator;
  final bool deletedByAdmin;
  final String? languageCode;

  const PublicMessageDataModel({
    required this.id,
    required this.habitId,
    required this.challengeId,
    required this.creator,
    required this.threadId,
    required this.repliesTo,
    required this.createdAt,
    required this.updateAt,
    required this.content,
    required this.likeCount,
    required this.replyCount,
    required this.deletedByCreator,
    required this.deletedByAdmin,
    required this.languageCode,
  });

  factory PublicMessageDataModel.fromJson(Map<String, dynamic> json) {
    return PublicMessageDataModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String?,
      challengeId: json['challenge_id'] as String?,
      creator: json['creator'] as String,
      threadId: json['thread_id'] as String,
      repliesTo: json['replies_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updateAt: json['updated_at'] is String
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      content: json['content'] as String,
      likeCount: json['like_count'] as int,
      replyCount: json['reply_count'] as int,
      deletedByCreator: json['deleted_by_creator'] as bool,
      deletedByAdmin: json['deleted_by_admin'] as bool,
      languageCode: json['language_code'] as String?,
    );
  }

  PublicMessage toDomain() => PublicMessage(
        id: id,
        habitId: habitId,
        challengeId: challengeId,
        creator: creator,
        threadId: threadId,
        repliesTo: repliesTo,
        createdAt: createdAt,
        updateAt: updateAt,
        content: content,
        likeCount: likeCount,
        replyCount: replyCount,
        deletedByCreator: deletedByCreator,
        deletedByAdmin: deletedByAdmin,
        languageCode: languageCode,
      );

  @override
  List<Object?> get props => [
        id,
        habitId,
        challengeId,
        creator,
        threadId,
        repliesTo,
        createdAt,
        updateAt,
        content,
        likeCount,
        replyCount,
        deletedByCreator,
        deletedByAdmin,
        languageCode,
      ];
}
