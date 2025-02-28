import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit_category.dart';

class HabitCategoryDataModel extends Equatable {
  final String id;
  final Map<String, String> name;
  final String icon;

  const HabitCategoryDataModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory HabitCategoryDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return HabitCategoryDataModel(
      id: jsonObject['id'] as String,
      name: Map<String, String>.from(json.decode(jsonObject['name'])),
      icon: jsonObject['icon'] as String,
    );
  }

  HabitCategory toDomain() => HabitCategory(
        id: id,
        name: name,
        icon: icon,
      );

  @override
  List<Object?> get props => [id, name, icon];
}
