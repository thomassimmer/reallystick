class PublicMessage {
  String id;
  String? habitId;
  String? challengeId;
  String threadId;
  String creator;
  String? repliesTo;
  DateTime createdAt;
  DateTime? updateAt;
  String content;
  int likeCount;
  int replyCount;
  bool deletedByCreator;
  bool deletedByAdmin;
  String? languageCode;

  PublicMessage({
    required this.id,
    required this.habitId,
    required this.challengeId,
    required this.threadId,
    required this.creator,
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

  PublicMessage copyWith({
    String? id,
    String? habitId,
    String? challengeId,
    String? threadId,
    String? creator,
    String? repliesTo,
    DateTime? createdAt,
    DateTime? updateAt,
    String? content,
    int? likeCount,
    int? replyCount,
    bool? deletedByCreator,
    bool? deletedByAdmin,
    String? languageCode,
  }) {
    return PublicMessage(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      challengeId: challengeId ?? this.challengeId,
      threadId: threadId ?? this.threadId,
      creator: creator ?? this.creator,
      repliesTo: repliesTo ?? this.repliesTo,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      deletedByCreator: deletedByCreator ?? this.deletedByCreator,
      deletedByAdmin: deletedByAdmin ?? this.deletedByAdmin,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
