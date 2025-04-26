import 'package:equatable/equatable.dart';

sealed class HabitDailyTrackingCreationEvent extends Equatable {
  const HabitDailyTrackingCreationEvent();

  @override
  List<Object?> get props => [];
}

class HabitDailyTrackingCreationFormHabitChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final String? habitId;

  const HabitDailyTrackingCreationFormHabitChangedEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class HabitDailyTrackingCreationFormQuantityPerSetChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final String quantityPerSet;

  const HabitDailyTrackingCreationFormQuantityPerSetChangedEvent(
    this.quantityPerSet,
  );

  @override
  List<Object?> get props => [quantityPerSet];
}

class HabitDailyTrackingCreationFormQuantityOfSetChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final int? quantityOfSet;

  const HabitDailyTrackingCreationFormQuantityOfSetChangedEvent(
      this.quantityOfSet);

  @override
  List<Object?> get props => [quantityOfSet];
}

class HabitDailyTrackingCreationFormUnitChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final String unitId;

  const HabitDailyTrackingCreationFormUnitChangedEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class HabitDailyTrackingCreationFormDateTimeChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final DateTime? datetime;

  const HabitDailyTrackingCreationFormDateTimeChangedEvent(this.datetime);

  @override
  List<Object?> get props => [datetime];
}

class HabitDailyTrackingCreationFormWeightChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final int weight;

  const HabitDailyTrackingCreationFormWeightChangedEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class HabitDailyTrackingCreationFormWeightUnitIdChangedEvent
    extends HabitDailyTrackingCreationEvent {
  final String weightUnitId;

  const HabitDailyTrackingCreationFormWeightUnitIdChangedEvent(
      this.weightUnitId);

  @override
  List<Object?> get props => [weightUnitId];
}
