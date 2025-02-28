import 'package:equatable/equatable.dart';

sealed class ChallengeDailyTrackingUpdateEvent extends Equatable {
  const ChallengeDailyTrackingUpdateEvent();

  @override
  List<Object?> get props => [];
}

class ChallengeDailyTrackingUpdateFormHabitChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final String? habitId;

  const ChallengeDailyTrackingUpdateFormHabitChangedEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final int? quantityPerSet;

  const ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent(
      this.quantityPerSet);

  @override
  List<Object?> get props => [quantityPerSet];
}

class ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final int? quantityOfSet;

  const ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent(
      this.quantityOfSet);

  @override
  List<Object?> get props => [quantityOfSet];
}

class ChallengeDailyTrackingUpdateFormUnitChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final String unitId;

  const ChallengeDailyTrackingUpdateFormUnitChangedEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class ChallengeDailyTrackingUpdateFormDateTimeChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final DateTime? datetime;

  const ChallengeDailyTrackingUpdateFormDateTimeChangedEvent(this.datetime);

  @override
  List<Object?> get props => [datetime];
}

class ChallengeDailyTrackingUpdateFormWeightChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final int weight;

  const ChallengeDailyTrackingUpdateFormWeightChangedEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

class ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent
    extends ChallengeDailyTrackingUpdateEvent {
  final String weightUnitId;

  const ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent(
      this.weightUnitId);

  @override
  List<Object?> get props => [weightUnitId];
}
