class HabitParticipationUpdateRequestModel {
  final String color;
  final bool toGain;

  const HabitParticipationUpdateRequestModel({
    required this.color,
    required this.toGain,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'to_gain': toGain,
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
