class PublicMessageUpdateRequestModel {
  final String content;

  const PublicMessageUpdateRequestModel({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

class PublicMessageCreateRequestModel {
  final String? habitId;
  final String? challengeId;
  final String? repliesTo;
  final String? threadId;
  final String content;

  const PublicMessageCreateRequestModel({
    required this.habitId,
    required this.challengeId,
    required this.repliesTo,
    required this.threadId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'challenge_id': challengeId,
      'replies_to': repliesTo,
      'thread_id': threadId,
      'content': content,
    };
  }
}
