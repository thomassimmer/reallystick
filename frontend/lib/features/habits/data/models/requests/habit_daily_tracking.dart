class HabitDailyTrackingUpdateRequestModel {
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;

  const HabitDailyTrackingUpdateRequestModel({
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String(),
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
    };
  }
}

class HabitDailyTrackingCreateRequestModel {
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;

  const HabitDailyTrackingCreateRequestModel({
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'datetime': datetime.toIso8601String(),
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
    };
  }
}
