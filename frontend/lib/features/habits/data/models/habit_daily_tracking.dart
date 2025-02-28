import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';

class HabitDailyTrackingDataModel extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;

  const HabitDailyTrackingDataModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.datetime,
    required this.quantityPerSet,
    required this.quantityOfSet,
    required this.unitId,
  });

  factory HabitDailyTrackingDataModel.fromJson(Map<String, dynamic> json) {
    return HabitDailyTrackingDataModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      quantityPerSet: json['quantity_per_set'] as int,
      quantityOfSet: json['quantity_of_set'] as int,
      unitId: json['unit_id'] as String,
    );
  }

  HabitDailyTracking toDomain() => HabitDailyTracking(
        id: id,
        userId: userId,
        habitId: habitId,
        datetime: datetime,
        quantityPerSet: quantityPerSet,
        quantityOfSet: quantityOfSet,
        unitId: unitId,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        habitId,
        datetime,
        quantityPerSet,
        quantityOfSet,
        unitId,
      ];
}
