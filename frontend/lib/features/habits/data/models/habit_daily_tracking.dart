import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';

class HabitDailyTrackingDataModel extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final DateTime day;
  final Duration? duration;
  final int? quantityPerSet;
  final int? quantityOfSet;
  final String? unit;
  final bool reset;

  const HabitDailyTrackingDataModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.day,
    this.duration,
    this.quantityPerSet,
    this.quantityOfSet,
    this.unit,
    required this.reset,
  });

  factory HabitDailyTrackingDataModel.fromJson(Map<String, dynamic> json) {
    return HabitDailyTrackingDataModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      day: DateTime.parse(json['day'] as String),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      quantityPerSet: json['quantity_per_set'] as int?,
      quantityOfSet: json['quantity_of_set'] as int?,
      unit: json['unit'] as String?,
      reset: json['reset'] as bool,
    );
  }

  HabitDailyTracking toDomain() => HabitDailyTracking(
        id: id,
        userId: userId,
        habitId: habitId,
        day: day,
        duration: duration,
        quantityPerSet: quantityPerSet,
        quantityOfSet: quantityOfSet,
        unit: unit,
        reset: reset,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        habitId,
        day,
        duration,
        quantityPerSet,
        quantityOfSet,
        unit,
        reset,
      ];
}
