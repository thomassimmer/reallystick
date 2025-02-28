import 'package:equatable/equatable.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';

class ChallengeDailyTrackingDataModel extends Equatable {
  final String id;
  final String habitId;
  final String challengeId;
  final DateTime datetime;
  final int quantityPerSet;
  final int quantityOfSet;
  final String unitId;
  final int weight;
  final String weightUnitId;

  const ChallengeDailyTrackingDataModel({
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

  factory ChallengeDailyTrackingDataModel.fromJson(Map<String, dynamic> json) {
    return ChallengeDailyTrackingDataModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      challengeId: json['challenge_id'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      quantityPerSet: json['quantity_per_set'] as int,
      quantityOfSet: json['quantity_of_set'] as int,
      unitId: json['unit_id'] as String,
      weight: json['weight'] as int,
      weightUnitId: json['weight_unit_id'] as String,
    );
  }

  ChallengeDailyTracking toDomain() => ChallengeDailyTracking(
        id: id,
        habitId: habitId,
        challengeId: challengeId,
        datetime: datetime,
        quantityPerSet: quantityPerSet,
        quantityOfSet: quantityOfSet,
        unitId: unitId,
        weight: weight,
        weightUnitId: weightUnitId,
      );

  @override
  List<Object?> get props => [
        id,
        habitId,
        challengeId,
        datetime,
        quantityPerSet,
        quantityOfSet,
        unitId,
        weight,
        weightUnitId
      ];
}
