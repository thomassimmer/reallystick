import 'dart:collection';

class HabitUpdateRequestModel {
  final Map<String, String> shortName;
  final Map<String, String> longName;
  final Map<String, String> description;
  final String categoryId;
  final bool reviewed;
  final String icon;
  final HashSet<String> unitIds;

  const HabitUpdateRequestModel({
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.reviewed,
    required this.icon,
    required this.unitIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'short_name': shortName,
      'long_name': longName,
      'description': description,
      'category_id': categoryId,
      'reviewed': reviewed,
      'icon': icon,
      'unit_ids': unitIds.toList(),
    };
  }
}

class HabitCreateRequestModel {
  final Map<String, String> shortName;
  final Map<String, String> longName;
  final Map<String, String> description;
  final String categoryId;
  final String icon;
  final HashSet<String> unitIds;

  const HabitCreateRequestModel({
    required this.shortName,
    required this.longName,
    required this.description,
    required this.categoryId,
    required this.icon,
    required this.unitIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'short_name': shortName,
      'long_name': longName,
      'description': description,
      'category_id': categoryId,
      'icon': icon,
      'unit_ids': unitIds.toList(),
    };
  }
}
