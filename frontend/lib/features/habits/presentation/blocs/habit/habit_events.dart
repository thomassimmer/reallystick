import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class HabitInitializeEvent extends HabitEvent {}

class CreateHabitEvent extends HabitEvent {
  final String shortName;
  final String longName;
  final String description;
  final String categoryId;
  final int icon;
  final String locale;

  const CreateHabitEvent({
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.locale,
  });

  @override
  List<Object?> get props => [
        shortName,
        longName,
        description,
        categoryId,
        icon,
        locale,
      ];
}
