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

class HabitMergeFormShortNameChangedEvent extends HabitMergeFormEvent {
  final Map<String, String> shortName;

  const HabitMergeFormShortNameChangedEvent(this.shortName);

  @override
  List<Object?> get props => [shortName];
}

class HabitMergeFormLongNameChangedEvent extends HabitMergeFormEvent {
  final Map<String, String> longName;

  const HabitMergeFormLongNameChangedEvent(this.longName);

  @override
  List<Object?> get props => [longName];
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
