import 'package:equatable/equatable.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';

class ChallengeDailyTrackingDataModel extends Equatable {
  final String id;
  final String habitId;
  final String challengeId;
  final int dayOfProgram;
  final double quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;
  final String? note;
  final int orderInDay;

  const ChallengeDailyTrackingDataModel({
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

  factory ChallengeDailyTrackingDataModel.fromJson(Map<String, dynamic> json) {
    return ChallengeDailyTrackingDataModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      challengeId: json['challenge_id'] as String,
      dayOfProgram: json['day_of_program'] as int,
      quantityPerSet: json['quantity_per_set'] as double,
      quantityOfSet: json['quantity_of_set'] as int,
      unitId: json['unit_id'] as String,
      weight: json['weight'] as int,
      weightUnitId: json['weight_unit_id'] as String,
      note: json['note'] as String?,
      orderInDay: json['order_in_day'] as int,
    );
  }

  ChallengeDailyTracking toDomain() => ChallengeDailyTracking(
        id: id,
        habitId: habitId,
        challengeId: challengeId,
        dayOfProgram: dayOfProgram,
        quantityPerSet: quantityPerSet,
        quantityOfSet: quantityOfSet,
        unitId: unitId,
        weight: weight,
        weightUnitId: weightUnitId,
        note: note,
        orderInDay: orderInDay,
      );

  @override
  List<Object?> get props => [
        id,
        habitId,
        challengeId,
        dayOfProgram,
        quantityPerSet,
        quantityOfSet,
        unitId,
        weight,
        weightUnitId,
        note,
        orderInDay,
      ];
}
