class ChallengeDailyTrackingsGetRequestModel {
  final List<String> challengeIds;

  const ChallengeDailyTrackingsGetRequestModel({required this.challengeIds});

  Map<String, dynamic> toJson() {
    return {
      'challenge_ids': challengeIds,
    };
  }
}

class ChallengeDailyTrackingUpdateRequestModel {
  final String habitId;
  final int dayOfProgram;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;
  final String? note;

  const ChallengeDailyTrackingUpdateRequestModel({
    required this.habitId,
    required this.dayOfProgram,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'day_of_program': dayOfProgram,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
      'note': note,
    };
  }
}

class ChallengeDailyTrackingCreateRequestModel {
  final String challengeId;
  final String habitId;
  final int dayOfProgram;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;
  final int repeat;
  final String? note;

  const ChallengeDailyTrackingCreateRequestModel({
    required this.challengeId,
    required this.habitId,
    required this.dayOfProgram,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
    required this.repeat,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'habit_id': habitId,
      'day_of_program': dayOfProgram,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
      'repeat': repeat,
      'note': note,
    };
  }
}
