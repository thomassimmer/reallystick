class HabitDailyTracking {
  String id;
  String userId;
  String habitId;
  DateTime day;
  Duration? duration;
  int? quantityPerSet;
  int? quantityOfSet;
  String? unit;
  bool reset;

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
