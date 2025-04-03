import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit.dart';

class HabitDataModel extends Equatable {
  final String id;
  final Map<String, String> name;
  final String categoryId;
  final bool reviewed;
  final Map<String, String> description;
  final String icon;
  final HashSet<String> unitIds;

  const HabitDataModel(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.reviewed,
      required this.description,
      required this.icon,
      required this.unitIds});

  factory HabitDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return HabitDataModel(
      id: jsonObject['id'] as String,
      name: Map<String, String>.from(json.decode(jsonObject['name'])),
      categoryId: jsonObject['category_id'] as String,
      reviewed: jsonObject['reviewed'] as bool,
      description:
          Map<String, String>.from(json.decode(jsonObject['description'])),
      icon: jsonObject['icon'] as String,
      unitIds: HashSet<String>.from(json.decode(jsonObject['unit_ids'])),
    );
  }

  Habit toDomain() => Habit(
        id: id,
        name: name,
        categoryId: categoryId,
        reviewed: reviewed,
        description: description,
        icon: icon,
        unitIds: unitIds,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        reviewed,
        description,
        icon,
        unitIds,
      ];
}
