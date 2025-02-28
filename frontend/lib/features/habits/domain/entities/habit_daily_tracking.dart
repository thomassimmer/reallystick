class HabitDailyTracking {
  final String id;
  final String userId;
  final String habitId;
  final DateTime day;
  final Duration? duration;
  final int? quantityPerSet;
  final int? quantityOfSet;
  final String? unit;
  final bool reset;

  HabitDailyTracking({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.day,
    this.duration,
    this.quantityPerSet,
    this.quantityOfSet,
    this.unit,
    required this.reset,
  });
}
