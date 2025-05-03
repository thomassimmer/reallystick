import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_creation/habit_creation_states.dart';

class HabitCreationFormBloc
    extends Bloc<HabitCreationFormEvent, HabitCreationFormState> {
  HabitCreationFormBloc() : super(const HabitCreationFormState()) {
    on<HabitCreationFormCategoryChangedEvent>(_categoryChanged);
    on<HabitCreationFormNameChangedEvent>(_nameChanged);
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
          state.name,
          state.description,
          state.icon,
          ...state.unitIds.values
        ]),
      ),
    );
  }

  Future<void> _nameChanged(
      HabitCreationFormNameChangedEvent event, Emitter emit) async {
    final name = HabitNameValidator.dirty(event.name);

    emit(
      state.copyWith(
        name: name,
        isValid: Formz.validate([
          state.habitCategory,
          name,
          state.description,
          state.icon,
          ...state.unitIds.values
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
          state.name,
          description,
          state.icon,
          ...state.unitIds.values
        ]),
      ),
    );
  }

  Future<void> _iconChanged(
      HabitCreationFormIconChangedEvent event, Emitter emit) async {
    final icon = IconValidator.dirty(event.icon);

    emit(
      state.copyWith(
        icon: icon,
        isValid: Formz.validate([
          state.habitCategory,
          state.name,
          state.description,
          icon,
          ...state.unitIds.values
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
          state.name,
          state.description,
          state.icon,
          ...unitIdsMap.values
        ]),
      ),
    );
  }
}
