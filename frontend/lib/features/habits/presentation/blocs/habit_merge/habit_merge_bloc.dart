import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_states.dart';

class HabitMergeFormBloc
    extends Bloc<HabitMergeFormEvent, HabitMergeFormState> {
  HabitMergeFormBloc() : super(const HabitMergeFormState()) {
    on<HabitMergeFormChangedEvent>(_habitChanged);
    on<HabitMergeFormCategoryChangedEvent>(_categoryChanged);
    on<HabitMergeFormNameChangedEvent>(_nameChanged);
    on<HabitMergeFormDescriptionChangedEvent>(_descriptionChanged);
    on<HabitMergeFormIconChangedEvent>(_iconChanged);
    on<HabitMergeFormUnitsChangedEvent>(_unitsChanged);
  }

  Future<void> _habitChanged(
      HabitMergeFormChangedEvent event, Emitter emit) async {
    final habit = HabitValidator.dirty(event.habit);

    emit(
      state.copyWith(
        habitToMergeOn: habit,
        isValid: Formz.validate([
          habit,
          ...state.name.values,
          ...state.description.values,
          state.icon,
          state.habitCategory,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _categoryChanged(
      HabitMergeFormCategoryChangedEvent event, Emitter emit) async {
    final habitCategory = HabitCategoryValidator.dirty(event.habitCategory);

    emit(
      state.copyWith(
        habitCategory: habitCategory,
        isValid: Formz.validate([
          habitCategory,
          ...state.name.values,
          ...state.description.values,
          state.icon,
          state.habitToMergeOn,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _nameChanged(
      HabitMergeFormNameChangedEvent event, Emitter emit) async {
    final Map<String, HabitNameValidator> nameMap = {};

    if (event.name.values.every((value) => value.isEmpty)) {
      nameMap[event.name.keys.first] =
          HabitNameValidator.dirty('No translation entered');
    } else {
      for (final entry in event.name.entries) {
        nameMap[entry.key] = HabitNameValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        name: nameMap,
        isValid: Formz.validate([
          ...state.name.values,
          ...state.description.values,
          state.icon,
          state.habitCategory,
          state.habitToMergeOn,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _descriptionChanged(
      HabitMergeFormDescriptionChangedEvent event, Emitter emit) async {
    final Map<String, HabitDescriptionValidator> descriptionMap = {};

    if (event.description.values.every((value) => value.isEmpty)) {
      descriptionMap[event.description.keys.first] =
          HabitDescriptionValidator.dirty('No translation entered');
    } else {
      for (final entry in event.description.entries) {
        descriptionMap[entry.key] =
            HabitDescriptionValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        description: descriptionMap,
        isValid: Formz.validate([
          ...state.name.values,
          ...state.description.values,
          state.icon,
          state.habitCategory,
          state.habitToMergeOn,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _iconChanged(
      HabitMergeFormIconChangedEvent event, Emitter emit) async {
    final icon = IconValidator.dirty(event.icon);

    emit(
      state.copyWith(
        icon: icon,
        isValid: Formz.validate([
          state.habitCategory,
          ...state.name.values,
          ...state.description.values,
          icon,
          state.habitToMergeOn,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _unitsChanged(
      HabitMergeFormUnitsChangedEvent event, Emitter emit) async {
    final Map<String, UnitValidator> unitIdsMap = {};

    if (event.unitIds.isEmpty) {
      unitIdsMap['error'] = UnitValidator.dirty('No unit selected');
    }

    for (final entry in event.unitIds) {
      unitIdsMap[entry] = UnitValidator.dirty(entry);
    }

    emit(
      state.copyWith(
        unitIds: unitIdsMap,
        isValid: Formz.validate([
          state.habitCategory,
          ...state.name.values,
          ...state.description.values,
          state.icon,
          ...unitIdsMap.values
        ]),
      ),
    );
  }
}
