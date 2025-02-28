import 'dart:collection';

import 'package:equatable/equatable.dart';

sealed class HabitCreationFormEvent extends Equatable {
  const HabitCreationFormEvent();

  @override
  List<Object?> get props => [];
}

class HabitCreationFormCategoryChangedEvent extends HabitCreationFormEvent {
  final String habitCategory;

  const HabitCreationFormCategoryChangedEvent(this.habitCategory);

  @override
  List<Object?> get props => [habitCategory];
}

class HabitCreationFormShortNameChangedEvent extends HabitCreationFormEvent {
  final String shortName;

  const HabitCreationFormShortNameChangedEvent(this.shortName);

  @override
  List<Object?> get props => [shortName];
}

class HabitCreationFormLongNameChangedEvent extends HabitCreationFormEvent {
  final String longName;

  const HabitCreationFormLongNameChangedEvent(this.longName);

  @override
  List<Object?> get props => [longName];
}

class HabitCreationFormDescriptionChangedEvent extends HabitCreationFormEvent {
  final String description;

  const HabitCreationFormDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class HabitCreationFormIconChangedEvent extends HabitCreationFormEvent {
  final String icon;

  const HabitCreationFormIconChangedEvent(this.icon);

  @override
  List<Object?> get props => [icon];
}

class HabitCreationFormUnitsChangedEvent extends HabitCreationFormEvent {
  final HashSet<String> unitIds;

  const HabitCreationFormUnitsChangedEvent(this.unitIds);

  @override
  List<Object?> get props => [unitIds];
}
