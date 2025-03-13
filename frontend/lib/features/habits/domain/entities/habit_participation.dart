class HabitParticipation {
  String id;
  String userId;
  String habitId;
  String color;
  bool toGain;
  bool notificationsReminderEnabled;
  String? reminderTime;
  String? reminderBody;

  HabitParticipation({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.color,
    required this.toGain,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
  });
}
