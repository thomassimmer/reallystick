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
}
