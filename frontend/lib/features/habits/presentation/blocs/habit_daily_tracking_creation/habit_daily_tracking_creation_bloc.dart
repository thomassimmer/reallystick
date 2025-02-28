import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/datetime.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_daily_tracking_creation/habit_daily_tracking_creation_states.dart';

class HabitDailyTrackingCreationFormBloc extends Bloc<
    HabitDailyTrackingCreationEvent, HabitDailyTrackingCreationFormState> {
  HabitDailyTrackingCreationFormBloc()
      : super(const HabitDailyTrackingCreationFormState()) {
    on<HabitDailyTrackingCreationFormHabitChangedEvent>(_habitChanged);
    on<HabitDailyTrackingCreationFormQuantityPerSetChangedEvent>(
        _quantityPerSetChanged);
    on<HabitDailyTrackingCreationFormQuantityOfSetChangedEvent>(
        _quantityOfSetChanged);
    on<HabitDailyTrackingCreationFormUnitChangedEvent>(_unitChanged);
    on<HabitDailyTrackingCreationFormDateTimeChangedEvent>(_datetimeChanged);
    on<HabitDailyTrackingCreationFormWeightChangedEvent>(_weightChanged);
    on<HabitDailyTrackingCreationFormWeightUnitIdChangedEvent>(
        _weightUnitChanged);
  }

  Future<void> _habitChanged(
      HabitDailyTrackingCreationFormHabitChangedEvent event,
      Emitter emit) async {
    final habitId = HabitValidator.dirty(event.habitId);

    emit(
      state.copyWith(
        habitId: habitId,
        isValid: Formz.validate([
          habitId,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityPerSetChanged(
      HabitDailyTrackingCreationFormQuantityPerSetChangedEvent event,
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
          state.habitId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityOfSetChanged(
      HabitDailyTrackingCreationFormQuantityOfSetChangedEvent event,
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
          state.habitId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _unitChanged(
      HabitDailyTrackingCreationFormUnitChangedEvent event,
      Emitter emit) async {
    final unitId = UnitValidator.dirty(event.unitId);

    emit(
      state.copyWith(
        unitId: unitId,
        isValid: Formz.validate([
          unitId,
          state.quantityOfSet,
          state.quantityPerSet,
          state.habitId,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _datetimeChanged(
      HabitDailyTrackingCreationFormDateTimeChangedEvent event,
      Emitter emit) async {
    final datetime = DateTimeValidator.dirty(event.datetime);

    emit(
      state.copyWith(
        datetime: datetime,
        isValid: Formz.validate([
          datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.habitId,
          state.unitId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightChanged(
      HabitDailyTrackingCreationFormWeightChangedEvent event,
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
          state.habitId,
          state.unitId,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightUnitChanged(
      HabitDailyTrackingCreationFormWeightUnitIdChangedEvent event,
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
          state.habitId,
          state.unitId,
        ]),
      ),
    );
  }
}
