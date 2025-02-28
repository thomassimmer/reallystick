import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/datetime.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';

final class HabitDailyTrackingCreationFormState extends Equatable {
  const HabitDailyTrackingCreationFormState({
    this.habitId = const HabitValidator.pure(),
    this.quantityOfSet = const QuantityOfSetValidator.pure(),
    this.quantityPerSet = const QuantityPerSetValidator.pure(),
    this.unitId = const UnitValidator.pure(),
    this.datetime = const DateTimeValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  final HabitValidator habitId;
  final QuantityOfSetValidator quantityOfSet;
  final QuantityPerSetValidator quantityPerSet;
  final UnitValidator unitId;
  final DateTimeValidator datetime;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        habitId,
        quantityOfSet,
        quantityPerSet,
        unitId,
        datetime,
        isValid,
        errorMessage,
      ];

  HabitDailyTrackingCreationFormState copyWith({
    HabitValidator? habitId,
    QuantityOfSetValidator? quantityOfSet,
    QuantityPerSetValidator? quantityPerSet,
    UnitValidator? unitId,
    DateTimeValidator? datetime,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitDailyTrackingCreationFormState(
      habitId: habitId ?? this.habitId,
      quantityOfSet: quantityOfSet ?? this.quantityOfSet,
      quantityPerSet: quantityPerSet ?? this.quantityPerSet,
      unitId: unitId ?? this.unitId,
      datetime: datetime ?? this.datetime,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
