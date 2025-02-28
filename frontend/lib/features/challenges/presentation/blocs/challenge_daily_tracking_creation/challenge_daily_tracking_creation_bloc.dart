import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/habit_daily_tracking_datetime.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_creation/challenge_daily_tracking_creation_states.dart';

class ChallengeDailyTrackingCreationFormBloc extends Bloc<
    ChallengeDailyTrackingCreationEvent,
    ChallengeDailyTrackingCreationFormState> {
  ChallengeDailyTrackingCreationFormBloc()
      : super(const ChallengeDailyTrackingCreationFormState()) {
    on<ChallengeDailyTrackingCreationFormHabitChangedEvent>(_habitChanged);
    on<ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent>(
        _quantityPerSetChanged);
    on<ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent>(
        _quantityOfSetChanged);
    on<ChallengeDailyTrackingCreationFormUnitChangedEvent>(_unitChanged);
    on<ChallengeDailyTrackingCreationFormDateTimeChangedEvent>(
        _datetimeChanged);
    on<ChallengeDailyTrackingCreationFormWeightChangedEvent>(_weightChanged);
    on<ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent>(
        _weightUnitChanged);
  }

  Future<void> _habitChanged(
      ChallengeDailyTrackingCreationFormHabitChangedEvent event,
      Emitter emit) async {
    final habitId = HabitValidator.dirty(event.habitId);

    emit(
      state.copyWith(
        habitId: habitId,
        isValid: Formz.validate([
          state.challengeId,
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
      ChallengeDailyTrackingCreationFormQuantityPerSetChangedEvent event,
      Emitter emit) async {
    final quantityPerSet = QuantityPerSetValidator.dirty(event.quantityPerSet);

    emit(
      state.copyWith(
        quantityPerSet: quantityPerSet,
        isValid: Formz.validate([
          quantityPerSet,
          state.habitId,
          state.quantityOfSet,
          state.unitId,
          state.datetime,
          state.challengeId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityOfSetChanged(
      ChallengeDailyTrackingCreationFormQuantityOfSetChangedEvent event,
      Emitter emit) async {
    final quantityOfSet = QuantityOfSetValidator.dirty(event.quantityOfSet);

    emit(
      state.copyWith(
        quantityOfSet: quantityOfSet,
        isValid: Formz.validate([
          quantityOfSet,
          state.habitId,
          state.quantityPerSet,
          state.unitId,
          state.datetime,
          state.challengeId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _unitChanged(
      ChallengeDailyTrackingCreationFormUnitChangedEvent event,
      Emitter emit) async {
    final unitId = UnitValidator.dirty(event.unitId);

    emit(
      state.copyWith(
        unitId: unitId,
        isValid: Formz.validate([
          unitId,
          state.habitId,
          state.quantityOfSet,
          state.quantityPerSet,
          state.challengeId,
          state.datetime,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _datetimeChanged(
      ChallengeDailyTrackingCreationFormDateTimeChangedEvent event,
      Emitter emit) async {
    final datetime = HabitDailyTrackingDatetime.dirty(event.datetime);

    emit(
      state.copyWith(
        datetime: datetime,
        isValid: Formz.validate([
          datetime,
          state.habitId,
          state.quantityOfSet,
          state.quantityPerSet,
          state.challengeId,
          state.unitId,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightChanged(
      ChallengeDailyTrackingCreationFormWeightChangedEvent event,
      Emitter emit) async {
    final weight = WeightValidator.dirty(event.weight);

    emit(
      state.copyWith(
        weight: weight,
        isValid: Formz.validate([
          weight,
          state.habitId,
          state.datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.challengeId,
          state.unitId,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightUnitChanged(
      ChallengeDailyTrackingCreationFormWeightUnitIdChangedEvent event,
      Emitter emit) async {
    final weightUnitId = UnitValidator.dirty(event.weightUnitId);

    emit(
      state.copyWith(
        weightUnitId: weightUnitId,
        isValid: Formz.validate([
          weightUnitId,
          state.habitId,
          state.weight,
          state.datetime,
          state.quantityOfSet,
          state.quantityPerSet,
          state.challengeId,
          state.unitId,
        ]),
      ),
    );
  }
}
