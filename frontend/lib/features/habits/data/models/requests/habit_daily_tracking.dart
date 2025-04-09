class HabitDailyTrackingUpdateRequestModel {
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const HabitDailyTrackingUpdateRequestModel({
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
    required this.weight,
    required this.weightUnitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String().split('.').first,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
    };
  }
}

class HabitDailyTrackingCreateRequestModel {
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const HabitDailyTrackingCreateRequestModel({
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
      'datetime': datetime.toIso8601String().split('.').first,
      'quantity_per_set': quantityPerSet,
      'quantity_of_set': quantityOfSet,
      'unit_id': unitId,
      'weight': weight,
      'weight_unit_id': weightUnitId,
    };
  }
}
