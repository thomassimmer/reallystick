class HabitDailyTracking {
  String id;
  String userId;
  String habitId;
  DateTime datetime;
  int quantityPerSet;
  int quantityOfSet;
  String unitId;
  int weight;
  String weightUnitId;

  HabitDailyTracking({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });
}
