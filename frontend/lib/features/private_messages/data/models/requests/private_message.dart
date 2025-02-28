class PrivateMessageUpdateRequestModel {
  final String content;

  const PrivateMessageUpdateRequestModel({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

class PrivateMessageCreateRequestModel {
  final String discussionId;
  final String content;
  final String creatorEncryptedSessionKey;
  final String recipientEncryptedSessionKey;

  const PrivateMessageCreateRequestModel({
    required this.discussionId,
    required this.content,
    required this.creatorEncryptedSessionKey,
    required this.recipientEncryptedSessionKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'creator_encrypted_session_key': creatorEncryptedSessionKey,
      'recipient_encrypted_session_key': recipientEncryptedSessionKey,
      'discussion_id': discussionId,
      'content': content,
    };
  }
}
