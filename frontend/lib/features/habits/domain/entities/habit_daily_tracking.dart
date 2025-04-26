import 'package:equatable/equatable.dart';

class HabitDailyTracking extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final DateTime datetime;
  final double quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

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

  @override
  List<Object> get props => [
        id,
        userId,
        habitId,
        datetime,
        quantityPerSet,
        quantityOfSet,
        unitId,
        weight,
        weightUnitId,
      ];

  HabitDailyTracking copyWith({
    String? id,
    String? userId,
    String? habitId,
    DateTime? datetime,
    double? quantityPerSet,
    int? quantityOfSet,
    String? unitId,
    int? weight,
    String? weightUnitId,
  }) {
    return HabitDailyTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      datetime: datetime ?? this.datetime,
      quantityPerSet: quantityPerSet ?? this.quantityPerSet,
      quantityOfSet: quantityOfSet ?? this.quantityOfSet,
      unitId: unitId ?? this.unitId,
      weight: weight ?? this.weight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
    );
  }
}
