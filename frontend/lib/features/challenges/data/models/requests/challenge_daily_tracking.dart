class ChallengeDailyTrackingUpdateRequestModel {
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const ChallengeDailyTrackingUpdateRequestModel({
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'datetime': datetime.toUtc().toIso8601String(),
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
    };
  }
}

class ChallengeDailyTrackingCreateRequestModel {
  final String challengeId;
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const ChallengeDailyTrackingCreateRequestModel({
    required this.challengeId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'habit_id': habitId,
      'datetime': datetime.toUtc().toIso8601String(),
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
    };
  }
}
