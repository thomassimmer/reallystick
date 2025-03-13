import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/habit_category.dart';
import 'package:reallystick/core/validators/habit_long_name.dart';
import 'package:reallystick/core/validators/habit_short_name.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/core/validators/unit.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_events.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit_review/habit_review_states.dart';

class HabitReviewFormBloc
    extends Bloc<HabitReviewFormEvent, HabitReviewFormState> {
  HabitReviewFormBloc() : super(const HabitReviewFormState()) {
    on<HabitReviewFormCategoryChangedEvent>(_categoryChanged);
    on<HabitReviewFormShortNameChangedEvent>(_shortNameChanged);
    on<HabitReviewFormLongNameChangedEvent>(_longNameChanged);
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
          ...state.shortName.values,
          ...state.longName.values,
          ...state.description.values,
          state.icon,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _shortNameChanged(
      HabitReviewFormShortNameChangedEvent event, Emitter emit) async {
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
          ...state.shortName.values,
          ...state.longName.values,
          ...state.description.values,
          state.icon,
          state.habitCategory,
          ...state.unitIds.values,
        ]),
      ),
    );
  }

  Future<void> _longNameChanged(
      HabitReviewFormLongNameChangedEvent event, Emitter emit) async {
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
          ...state.shortName.values,
          ...state.longName.values,
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
          ...state.shortName.values,
          ...state.longName.values,
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
          ...state.shortName.values,
          ...state.longName.values,
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

    for (final entry in event.unitIds) {
      unitIdsMap[entry] = UnitValidator.dirty(entry);
    }

    emit(
      state.copyWith(
        unitIds: unitIdsMap,
        isValid: Formz.validate([
          state.habitCategory,
          ...state.shortName.values,
          ...state.longName.values,
          ...state.description.values,
          state.icon,
          ...unitIdsMap.values
        ]),
      ),
    );
  }
}
