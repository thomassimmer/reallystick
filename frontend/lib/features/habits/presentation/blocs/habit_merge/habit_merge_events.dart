import 'dart:collection';

import 'package:equatable/equatable.dart';

sealed class HabitMergeFormEvent extends Equatable {
  const HabitMergeFormEvent();

  @override
  List<Object?> get props => [];
}

class HabitMergeFormChangedEvent extends HabitMergeFormEvent {
  final String habit;

  const HabitMergeFormChangedEvent(this.habit);

  @override
  List<Object?> get props => [habit];
}

class HabitMergeFormCategoryChangedEvent extends HabitMergeFormEvent {
  final String habitCategory;

  const HabitMergeFormCategoryChangedEvent(this.habitCategory);

  @override
  List<Object?> get props => [habitCategory];
}

class HabitMergeFormNameChangedEvent extends HabitMergeFormEvent {
  final Map<String, String> name;

  const HabitMergeFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class HabitMergeFormDescriptionChangedEvent extends HabitMergeFormEvent {
  final Map<String, String> description;

  const HabitMergeFormDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class HabitMergeFormIconChangedEvent extends HabitMergeFormEvent {
  final String icon;

  const HabitMergeFormIconChangedEvent(this.icon);

  @override
  List<Object?> get props => [icon];
}

class HabitMergeFormUnitsChangedEvent extends HabitMergeFormEvent {
  final HashSet<String> unitIds;

  const HabitMergeFormUnitsChangedEvent(this.unitIds);

  @override
  List<Object?> get props => [unitIds];
}
