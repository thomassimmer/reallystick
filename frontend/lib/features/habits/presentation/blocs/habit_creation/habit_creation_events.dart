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

class HabitCreationFormNameChangedEvent extends HabitCreationFormEvent {
  final String name;

  const HabitCreationFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
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
