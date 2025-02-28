import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/datetime.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
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
          state.habitId
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
          state.habitId
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
        ]),
      ),
    );
  }
}
