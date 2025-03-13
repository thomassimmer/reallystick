class HabitParticipationUpdateRequestModel {
  final String color;
  final bool toGain;
  final bool notificationsReminderEnabled;
  final String? reminderTime;
  final String? reminderBody;

  const HabitParticipationUpdateRequestModel({
    required this.color,
    required this.toGain,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'to_gain': toGain,
      'notifications_reminder_enabled': notificationsReminderEnabled,
      'reminder_time': reminderTime,
      'reminder_body': reminderBody,
    };
  }
}

class HabitParticipationCreateRequestModel {
  final String habitId;
  final String color;
  final bool toGain;

  const HabitParticipationCreateRequestModel({
    required this.habitId,
    required this.color,
    required this.toGain,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'color': color,
      'to_gain': toGain,
    };
  }
}
