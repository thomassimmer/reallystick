import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_description.dart';
import 'package:reallystick/core/validators/habit_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_states.dart';

class HabitReviewFormBloc
    extends Bloc<HabitReviewFormEvent, HabitReviewFormState> {
  HabitReviewFormBloc() : super(const HabitReviewFormState()) {
    on<HabitReviewFormCategoryChangedEvent>(_categoryChanged);
    on<HabitReviewFormNameChangedEvent>(_nameChanged);
    on<HabitReviewFormDescriptionChangedEvent>(_descriptionChanged);
    on<HabitReviewFormIconChangedEvent>(_iconChanged);
    on<HabitReviewFormUnitsChangedEvent>(_unitsChanged);
  }

  Future<void> _categoryChanged(
      HabitReviewFormCategoryChangedEvent event, Emitter emit) async {
    final habitCategory = HabitCategoryValidator.dirty(event.habitCategory);

    emit(
      state.copyWith(
        habitCategory: habitCategory,
        isValid: Formz.validate([
          habitCategory,
          ...state.name.values,
          ...state.description.values,
          state.icon,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _nameChanged(
      HabitReviewFormNameChangedEvent event, Emitter emit) async {
    final Map<String, HabitNameValidator> shortNameMap = {};

    if (event.name.entries.isEmpty) {
      shortNameMap['en'] = HabitNameValidator.dirty('No translation entered');
    } else {
      for (final entry in event.name.entries) {
        shortNameMap[entry.key] = HabitNameValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        name: shortNameMap,
        isValid: Formz.validate([
          ...state.name.values,
          ...state.description.values,
          state.icon,
          state.habitCategory,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _descriptionChanged(
      HabitReviewFormDescriptionChangedEvent event, Emitter emit) async {
    final Map<String, HabitDescriptionValidator> descriptionMap = {};

    if (event.description.entries.isEmpty) {
      descriptionMap['en'] =
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
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _iconChanged(
      HabitReviewFormIconChangedEvent event, Emitter emit) async {
    final icon = IconValidator.dirty(event.icon);

    emit(
      state.copyWith(
        icon: icon,
        isValid: Formz.validate([
          state.habitCategory,
          ...state.name.values,
          ...state.description.values,
          icon,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _unitsChanged(
      HabitReviewFormUnitsChangedEvent event, Emitter emit) async {
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
