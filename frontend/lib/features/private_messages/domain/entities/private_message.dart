class PrivateMessage {
  String id;
  String discussionId;
  String creator;
  DateTime createdAt;
  DateTime? updateAt;
  String content;
  String creatorEncryptedSessionKey;
  String recipientEncryptedSessionKey;
  bool deleted;
  bool seen;

  PrivateMessage({
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
}
