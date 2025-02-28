import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/habit.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_merge/habit_merge_states.dart';

class HabitMergeFormBloc
    extends Bloc<HabitMergeFormEvent, HabitMergeFormState> {
  HabitMergeFormBloc() : super(const HabitMergeFormState()) {
    on<HabitMergeFormChangedEvent>(_habitChanged);
    on<HabitMergeFormCategoryChangedEvent>(_categoryChanged);
    on<HabitMergeFormShortNameChangedEvent>(_shortNameChanged);
    on<HabitMergeFormLongNameChangedEvent>(_longNameChanged);
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
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          state.habitCategory,
          ...state.unitIds.values.toList(),
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
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          state.habitToMergeOn,
          ...state.unitIds.values.toList(),
        ]),
      ),
    );
  }

  Future<void> _shortNameChanged(
      HabitMergeFormShortNameChangedEvent event, Emitter emit) async {
    final Map<String, HabitShortNameValidator> shortNameMap = {};

    if (event.shortName.entries.isEmpty) {
      shortNameMap['en'] =
          HabitShortNameValidator.dirty('No translation entered');
    } else {
      for (final entry in event.shortName.entries) {
        shortNameMap[entry.key] = HabitShortNameValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        shortName: shortNameMap,
        isValid: Formz.validate([
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          state.habitCategory,
          state.habitToMergeOn,
          ...state.unitIds.values.toList(),
        ]),
      ),
    );
  }

  Future<void> _longNameChanged(
      HabitMergeFormLongNameChangedEvent event, Emitter emit) async {
    final Map<String, HabitLongNameValidator> longNameMap = {};

    if (event.longName.entries.isEmpty) {
      longNameMap['en'] =
          HabitLongNameValidator.dirty('No translation entered');
    } else {
      for (final entry in event.longName.entries) {
        longNameMap[entry.key] = HabitLongNameValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        longName: longNameMap,
        isValid: Formz.validate([
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          state.habitCategory,
          state.habitToMergeOn,
          ...state.unitIds.values.toList(),
        ]),
      ),
    );
  }

  Future<void> _descriptionChanged(
      HabitMergeFormDescriptionChangedEvent event, Emitter emit) async {
    final Map<String, DescriptionValidator> descriptionMap = {};

    if (event.description.entries.isEmpty) {
      descriptionMap['en'] =
          DescriptionValidator.dirty('No translation entered');
    } else {
      for (final entry in event.description.entries) {
        descriptionMap[entry.key] = DescriptionValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        description: descriptionMap,
        isValid: Formz.validate([
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          state.habitCategory,
          state.habitToMergeOn,
          ...state.unitIds.values.toList(),
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
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          icon,
          state.habitToMergeOn,
          ...state.unitIds.values.toList(),
        ]),
      ),
    );
  }

  Future<void> _unitsChanged(
      HabitMergeFormUnitsChangedEvent event, Emitter emit) async {
    final Map<String, UnitValidator> unitIdsMap = {};

    for (final entry in event.unitIds) {
      unitIdsMap[entry] = UnitValidator.dirty(entry);
    }

    emit(
      state.copyWith(
        unitIds: unitIdsMap,
        isValid: Formz.validate([
          state.habitCategory,
          ...state.shortName.values.toList(),
          ...state.longName.values.toList(),
          ...state.description.values.toList(),
          state.icon,
          ...unitIdsMap.values.toList()
        ]),
      ),
    );
  }
}
