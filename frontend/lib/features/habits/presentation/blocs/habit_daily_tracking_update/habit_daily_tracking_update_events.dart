import 'package:equatable/equatable.dart';

sealed class HabitDailyTrackingUpdateEvent extends Equatable {
  const HabitDailyTrackingUpdateEvent();

  @override
  List<Object?> get props => [];
}

class HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent
    extends HabitDailyTrackingUpdateEvent {
  final int? quantityPerSet;

  const HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent(
      this.quantityPerSet);

  @override
  List<Object?> get props => [quantityPerSet];
}

class HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent
    extends HabitDailyTrackingUpdateEvent {
  final int? quantityOfSet;

  const HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent(
      this.quantityOfSet);

  @override
  List<Object?> get props => [quantityOfSet];
}

class HabitDailyTrackingUpdateFormUnitChangedEvent
    extends HabitDailyTrackingUpdateEvent {
  final String unitId;

  const HabitDailyTrackingUpdateFormUnitChangedEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}

class HabitDailyTrackingUpdateFormDateTimeChangedEvent
    extends HabitDailyTrackingUpdateEvent {
  final DateTime? datetime;

  const HabitDailyTrackingUpdateFormDateTimeChangedEvent(this.datetime);

  @override
  List<Object?> get props => [datetime];
}
