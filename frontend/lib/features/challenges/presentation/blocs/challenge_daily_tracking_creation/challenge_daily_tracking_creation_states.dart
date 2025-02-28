import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/challenge.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/habit_daily_tracking_datetime.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';

final class ChallengeDailyTrackingCreationFormState extends Equatable {
  final ChallengeValidator challengeId;
  final HabitValidator habitId;
  final QuantityOfSetValidator quantityOfSet;
  final QuantityPerSetValidator quantityPerSet;
  final UnitValidator unitId;
  final HabitDailyTrackingDatetime datetime;
  final WeightValidator weight;
  final UnitValidator weightUnitId;
  final bool isValid;
  final String? errorMessage;

  const ChallengeDailyTrackingCreationFormState({
    this.challengeId = const ChallengeValidator.pure(),
    this.habitId = const HabitValidator.pure(),
    this.quantityOfSet = const QuantityOfSetValidator.pure(),
    this.quantityPerSet = const QuantityPerSetValidator.pure(),
    this.unitId = const UnitValidator.pure(),
    this.datetime = const HabitDailyTrackingDatetime.pure(),
    this.weight = const WeightValidator.pure(),
    this.weightUnitId = const UnitValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        challengeId,
        habitId,
        quantityOfSet,
        quantityPerSet,
        unitId,
        datetime,
        weight,
        weightUnitId,
        isValid,
        errorMessage,
      ];

  ChallengeDailyTrackingCreationFormState copyWith({
    ChallengeValidator? challengeId,
    HabitValidator? habitId,
    QuantityOfSetValidator? quantityOfSet,
    QuantityPerSetValidator? quantityPerSet,
    UnitValidator? unitId,
    HabitDailyTrackingDatetime? datetime,
    WeightValidator? weight,
    UnitValidator? weightUnitId,
    bool? isValid,
    String? errorMessage,
  }) {
    return ChallengeDailyTrackingCreationFormState(
      challengeId: challengeId ?? this.challengeId,
      habitId: habitId ?? this.habitId,
      quantityOfSet: quantityOfSet ?? this.quantityOfSet,
      quantityPerSet: quantityPerSet ?? this.quantityPerSet,
      unitId: unitId ?? this.unitId,
      datetime: datetime ?? this.datetime,
      weight: weight ?? this.weight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
