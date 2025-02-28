class ChallengeDailyTracking {
  String id;
  String habitId;
  String challengeId;
  DateTime datetime;
  int quantityPerSet;
  int quantityOfSet;
  String unitId;
  int weight;
  String weightUnitId;

  ChallengeDailyTracking({
    required this.id,
    required this.habitId,
    required this.challengeId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });
}
