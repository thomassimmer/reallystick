import 'package:equatable/equatable.dart';
import 'package:reallystick/core/validators/datetime.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';

final class HabitDailyTrackingUpdateFormState extends Equatable {
  const HabitDailyTrackingUpdateFormState({
    this.quantityOfSet = const QuantityOfSetValidator.pure(),
    this.quantityPerSet = const QuantityPerSetValidator.pure(),
    this.unitId = const UnitValidator.pure(),
    this.datetime = const DateTimeValidator.pure(),
    this.weight = const WeightValidator.pure(),
    this.weightUnitId = const UnitValidator.pure(),
    this.isValid = true,
    this.errorMessage,
  });

  final QuantityOfSetValidator quantityOfSet;
  final QuantityPerSetValidator quantityPerSet;
  final UnitValidator unitId;
  final DateTimeValidator datetime;
  final WeightValidator weight;
  final UnitValidator weightUnitId;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        quantityOfSet,
        quantityPerSet,
        unitId,
        datetime,
        weight,
        weightUnitId,
        isValid,
        errorMessage,
      ];

  HabitDailyTrackingUpdateFormState copyWith({
    QuantityOfSetValidator? quantityOfSet,
    QuantityPerSetValidator? quantityPerSet,
    UnitValidator? unitId,
    DateTimeValidator? datetime,
    WeightValidator? weight,
    UnitValidator? weightUnitId,
    bool? isValid,
    String? errorMessage,
  }) {
    return HabitDailyTrackingUpdateFormState(
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
