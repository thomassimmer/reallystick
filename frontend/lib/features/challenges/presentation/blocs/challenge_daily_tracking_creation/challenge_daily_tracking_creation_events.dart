import 'package:equatable/equatable.dart';

sealed class ChallengeDailyTrackingCreationEvent extends Equatable {
  const ChallengeDailyTrackingCreationEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeDailyTrackingCreationFormHabitChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final String? habitId;

  const ChallengeDailyTrackingCreationFormHabitChangedEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final int? quantityPerSet;

  const ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent(
      this.quantityPerSet);

  @override
  List<Object?> get props => [quantityPerSet];
}

class ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final int? quantityOfSet;

  const ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent(
      this.quantityOfSet);

  @override
  List<Object?> get props => [quantityOfSet];
}

class ChallengeDailyTrackingCreationFormUnitChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final String unitId;

  const ChallengeDailyTrackingCreationFormUnitChangedEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class ChallengeDailyTrackingCreationFormDayOfProgramChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final int dayOfProgram;

  const ChallengeDailyTrackingCreationFormDayOfProgramChangedEvent(
      this.dayOfProgram);

  @override
  List<Object?> get props => [dayOfProgram];
}

class ChallengeDailyTrackingCreationFormWeightChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final int weight;

  const ChallengeDailyTrackingCreationFormWeightChangedEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final String weightUnitId;

  const ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent(
      this.weightUnitId);

  @override
  List<Object?> get props => [weightUnitId];
}

class ChallengeDailyTrackingCreationFormRepeatChangedEvent
    extends ChallengeDailyTrackingCreationEvent {
  final int repeat;

  const ChallengeDailyTrackingCreationFormRepeatChangedEvent(this.repeat);

  @override
  List<Object?> get props => [repeat];
}
