import 'dart:collection';

import 'package:equatable/equatable.dart';

sealed class HabitReviewFormEvent extends Equatable {
  const HabitReviewFormEvent();

  @override
  List<Object?> get props => [];
}

class HabitReviewFormCategoryChangedEvent extends HabitReviewFormEvent {
  final String habitCategory;

  const HabitReviewFormCategoryChangedEvent(this.habitCategory);

  @override
  List<Object?> get props => [habitCategory];
}

class HabitReviewFormNameChangedEvent extends HabitReviewFormEvent {
  final Map<String, String> name;

  const HabitReviewFormNameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class HabitReviewFormDescriptionChangedEvent extends HabitReviewFormEvent {
  final Map<String, String> description;

  const HabitReviewFormDescriptionChangedEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class HabitReviewFormIconChangedEvent extends HabitReviewFormEvent {
  final String icon;

  const HabitReviewFormIconChangedEvent(this.icon);

  @override
  List<Object?> get props => [icon];
}

class HabitReviewFormUnitsChangedEvent extends HabitReviewFormEvent {
  final HashSet<String> unitIds;

  const HabitReviewFormUnitsChangedEvent(this.unitIds);

  @override
  List<Object?> get props => [unitIds];
}
