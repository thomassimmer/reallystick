import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/challenge_daily_tracking_datetime.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/quantity_of_set.dart';
import 'package:reallystick/core/validators/quantity_per_set.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/core/validators/weight.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_daily_tracking_update/challenge_daily_tracking_update_states.dart';

class ChallengeDailyTrackingUpdateFormBloc extends Bloc<
    ChallengeDailyTrackingUpdateEvent, ChallengeDailyTrackingUpdateFormState> {
  ChallengeDailyTrackingUpdateFormBloc()
      : super(const ChallengeDailyTrackingUpdateFormState()) {
    on<ChallengeDailyTrackingUpdateFormHabitChangedEvent>(_habitChanged);
    on<ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent>(
        _quantityPerSetChanged);
    on<ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent>(
        _quantityOfSetChanged);
    on<ChallengeDailyTrackingUpdateFormUnitChangedEvent>(_unitChanged);
    on<ChallengeDailyTrackingUpdateFormDayOfProgramChangedEvent>(
        _dayOfProgramChanged);
    on<ChallengeDailyTrackingUpdateFormWeightChangedEvent>(_weightChanged);
    on<ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent>(
        _weightUnitChanged);
  }

  Future<void> _habitChanged(
      ChallengeDailyTrackingUpdateFormHabitChangedEvent event,
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
          state.dayOfProgram,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityPerSetChanged(
      ChallengeDailyTrackingUpdateFormQuantityPerSetChangedEvent event,
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
          state.dayOfProgram,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _quantityOfSetChanged(
      ChallengeDailyTrackingUpdateFormQuantityOfSetChangedEvent event,
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
          state.dayOfProgram,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _unitChanged(
      ChallengeDailyTrackingUpdateFormUnitChangedEvent event,
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
          state.dayOfProgram,
          state.weight,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _dayOfProgramChanged(
      ChallengeDailyTrackingUpdateFormDayOfProgramChangedEvent event,
      Emitter emit) async {
    final dayOfProgram =
        ChallengeDailyTrackingDatetime.dirty(event.dayOfProgram);

    emit(
      state.copyWith(
        dayOfProgram: dayOfProgram,
        isValid: Formz.validate([
          dayOfProgram,
          state.habitId,
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
      ChallengeDailyTrackingUpdateFormWeightChangedEvent event,
      Emitter emit) async {
    final weight = WeightValidator.dirty(event.weight);

    emit(
      state.copyWith(
        weight: weight,
        isValid: Formz.validate([
          weight,
          state.habitId,
          state.dayOfProgram,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
          state.weightUnitId,
        ]),
      ),
    );
  }

  Future<void> _weightUnitChanged(
      ChallengeDailyTrackingUpdateFormWeightUnitIdChangedEvent event,
      Emitter emit) async {
    final weightUnitId = UnitValidator.dirty(event.weightUnitId);

    emit(
      state.copyWith(
        weightUnitId: weightUnitId,
        isValid: Formz.validate([
          weightUnitId,
          state.habitId,
          state.weight,
          state.dayOfProgram,
          state.quantityOfSet,
          state.quantityPerSet,
          state.unitId,
        ]),
      ),
    );
  }
}
