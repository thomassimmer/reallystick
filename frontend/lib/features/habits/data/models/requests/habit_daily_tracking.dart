class HabitDailyTrackingUpdateRequestModel {
  final DateTime day;
  final Duration? duration;
  final int? quantityPerSet;
  final int? quantityOfSet;
  final String? unit;
  final bool reset;

  const HabitDailyTrackingUpdateRequestModel({
    required this.day,
    this.duration,
    this.quantityPerSet,
    this.quantityOfSet,
    this.unit,
    required this.reset,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit': unit,
      'reset': reset,
    };
  }
}

class HabitDailyTrackingCreateRequestModel {
  final String habitId;
  final DateTime day;
  final Duration? duration;
  final int? quantityPerSet;
  final int? quantityOfSet;
  final String? unit;
  final bool reset;

  const HabitDailyTrackingCreateRequestModel({
    required this.habitId,
    required this.day,
    this.duration,
    this.quantityPerSet,
    this.quantityOfSet,
    this.unit,
    required this.reset,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'day': day.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit': unit,
      'reset': reset,
    };
  }
}
