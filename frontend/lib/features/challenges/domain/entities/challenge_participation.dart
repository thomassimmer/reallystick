class ChallengeParticipation {
  String id;
  String userId;
  String challengeId;
  String color;
  DateTime startDate;
  bool notificationsReminderEnabled;
  String? reminderTime;
  String? reminderBody;
  bool finished;

  ChallengeParticipation({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.color,
    required this.startDate,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
    required this.finished,
  });
}
