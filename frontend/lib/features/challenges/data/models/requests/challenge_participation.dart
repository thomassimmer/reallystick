class ChallengeParticipationUpdateRequestModel {
  final String color;
  final DateTime startDate;
  final bool notificationsReminderEnabled;
  final String? reminderTime;
  final String? reminderBody;
  final bool finished;

  const ChallengeParticipationUpdateRequestModel({
    required this.color,
    required this.startDate,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
    required this.finished,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'start_date': startDate.toUtc().toIso8601String(),
      'notifications_reminder_enabled': notificationsReminderEnabled,
      'reminder_time': reminderTime,
      'reminder_body': reminderBody,
      'finished': finished,
    };
  }
}

class ChallengeParticipationCreateRequestModel {
  final String challengeId;
  final String color;
  final DateTime startDate;

  const ChallengeParticipationCreateRequestModel({
    required this.challengeId,
    required this.color,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'color': color,
      'start_date': startDate.toUtc().toIso8601String(),
    };
  }
}
