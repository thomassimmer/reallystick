import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_icon.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_states.dart';

class HabitCreationFormBloc
    extends Bloc<HabitCreationFormEvent, HabitCreationFormState> {
  HabitCreationFormBloc() : super(const HabitCreationFormState()) {
    on<HabitCreationFormCategoryChangedEvent>(_categoryChanged);
    on<HabitCreationFormShortNameChangedEvent>(_shortNameChanged);
    on<HabitCreationFormLongNameChangedEvent>(_longNameChanged);
    on<HabitCreationFormDescriptionChangedEvent>(_descriptionChanged);
    on<HabitCreationFormIconChangedEvent>(_iconChanged);
    on<HabitCreationFormUnitsChangedEvent>(_unitsChanged);
  }

  Future<void> _categoryChanged(
      HabitCreationFormCategoryChangedEvent event, Emitter emit) async {
    final habitCategory = HabitCategoryValidator.dirty(event.habitCategory);

    emit(
      state.copyWith(
        habitCategory: habitCategory,
        isValid: Formz.validate([
          habitCategory,
          state.shortName,
          state.longName,
          state.description,
          state.icon,
          ...state.unitIds.values.toList()
        ]),
      ),
    );
  }

  Future<void> _shortNameChanged(
      HabitCreationFormShortNameChangedEvent event, Emitter emit) async {
    final shortName = HabitShortNameValidator.dirty(event.shortName);

    emit(
      state.copyWith(
        shortName: shortName,
        isValid: Formz.validate([
          state.habitCategory,
          shortName,
          state.longName,
          state.description,
          state.icon,
          ...state.unitIds.values.toList()
        ]),
      ),
    );
  }

  Future<void> _longNameChanged(
      HabitCreationFormLongNameChangedEvent event, Emitter emit) async {
    final longName = HabitLongNameValidator.dirty(event.longName);

    emit(
      state.copyWith(
        longName: longName,
        isValid: Formz.validate([
          state.habitCategory,
          state.shortName,
          longName,
          state.description,
          state.icon,
          ...state.unitIds.values.toList()
        ]),
      ),
    );
  }

  Future<void> _descriptionChanged(
      HabitCreationFormDescriptionChangedEvent event, Emitter emit) async {
    final description = HabitDescriptionValidator.dirty(event.description);

    emit(
      state.copyWith(
        description: description,
        isValid: Formz.validate([
          state.habitCategory,
          state.shortName,
          state.longName,
          description,
          state.icon,
          ...state.unitIds.values.toList()
        ]),
      ),
    );
  }

  Future<void> _iconChanged(
      HabitCreationFormIconChangedEvent event, Emitter emit) async {
    final icon = HabitIconValidator.dirty(event.icon);

    emit(
      state.copyWith(
        icon: icon,
        isValid: Formz.validate([
          state.habitCategory,
          state.shortName,
          state.longName,
          state.description,
          icon,
          ...state.unitIds.values.toList()
        ]),
      ),
    );
  }

  Future<void> _unitsChanged(
      HabitCreationFormUnitsChangedEvent event, Emitter emit) async {
    final Map<String, UnitValidator> unitIdsMap = {};

    for (final entry in event.unitIds) {
      unitIdsMap[entry] = UnitValidator.dirty(entry);
    }

    emit(
      state.copyWith(
        unitIds: unitIdsMap,
        isValid: Formz.validate([
          state.habitCategory,
          state.shortName,
          state.longName,
          state.description,
          state.icon,
          ...unitIdsMap.values.toList()
        ]),
      ),
    );
  }
}
