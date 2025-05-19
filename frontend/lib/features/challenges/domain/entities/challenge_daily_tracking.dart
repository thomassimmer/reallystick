class ChallengeDailyTracking {
  String id;
  String habitId;
  String challengeId;
  int dayOfProgram;
  double quantityPerSet;
  int quantityOfSet;
  String unitId;
  int weight;
  String weightUnitId;
  String? note;
  int orderInDay;

  ChallengeDailyTracking({
    required this.id,
    required this.habitId,
    required this.challengeId,
    required this.dayOfProgram,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
    required this.note,
    required this.orderInDay,
  });
}
