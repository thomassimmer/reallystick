class HabitDailyTracking {
  String id;
  String userId;
  String habitId;
  DateTime datetime;
  int quantityPerSet;
  int quantityOfSet;
  String unitId;

  HabitDailyTracking({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
  });
}
