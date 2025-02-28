import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/datetime.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_update/habit_daily_tracking_update_states.dart';

class HabitDailyTrackingUpdateFormBloc extends Bloc<
    HabitDailyTrackingUpdateEvent, HabitDailyTrackingUpdateFormState> {
  HabitDailyTrackingUpdateFormBloc()
      : super(const HabitDailyTrackingUpdateFormState()) {
    on<HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent>(
        _quantityPerSetChanged);
    on<HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent>(
        _quantityOfSetChanged);
    on<HabitDailyTrackingUpdateFormUnitChangedEvent>(_unitChanged);
    on<HabitDailyTrackingUpdateFormDateTimeChangedEvent>(_datetimeChanged);
    on<HabitDailyTrackingUpdateFormWeightChangedEvent>(_weightChanged);
    on<HabitDailyTrackingUpdateFormWeightUnitIdChangedEvent>(
        _weightUnitChanged);
  }

  Future<void> _quantityPerSetChanged(
      HabitDailyTrackingUpdateFormQuantityPerSetChangedEvent event,
      Emitter emit) async {
    final quantityPerSet = QuantityPerSetValidator.dirty(event.quantityPerSet);

    emit(
      state.copyWith(
        quantityPerSet: quantityPerSet,
        isValid: Formz.validate([
          quantityPerSet,
          state.quantityOfSet,
          state.unitId,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityOfSetChanged(
      HabitDailyTrackingUpdateFormQuantityOfSetChangedEvent event,
      Emitter emit) async {
    final quantityOfSet = QuantityOfSetValidator.dirty(event.quantityOfSet);

    emit(
      state.copyWith(
        quantityOfSet: quantityOfSet,
        isValid: Formz.validate([
          quantityOfSet,
          state.quantityPerSet,
          state.unitId,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _unitChanged(
      HabitDailyTrackingUpdateFormUnitChangedEvent event, Emitter emit) async {
    final unitId = UnitValidator.dirty(event.unitId);

    emit(
      state.copyWith(
        unitId: unitId,
        isValid: Formz.validate([
          unitId,
          state.quantityOfSet,
          state.quantityPerSet,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _datetimeChanged(
      HabitDailyTrackingUpdateFormDateTimeChangedEvent event,
      Emitter emit) async {
    final datetime = DateTimeValidator.dirty(event.datetime);

    emit(
      state.copyWith(
        datetime: datetime,
        isValid: Formz.validate([
          datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightChanged(
      HabitDailyTrackingUpdateFormWeightChangedEvent event,
      Emitter emit) async {
    final weight = WeightValidator.dirty(event.weight);

    emit(
      state.copyWith(
        weight: weight,
        isValid: Formz.validate([
          weight,
          state.datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightUnitChanged(
      HabitDailyTrackingUpdateFormWeightUnitIdChangedEvent event,
      Emitter emit) async {
    final weightUnitId = UnitValidator.dirty(event.weightUnitId);

    emit(
      state.copyWith(
        weightUnitId: weightUnitId,
        isValid: Formz.validate([
          weightUnitId,
          state.weight,
          state.datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
        ]),
      ),
    );
  }
}
