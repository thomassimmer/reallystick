import 'dart:collection';

class Habit {
  String id;
  Map<String, String> name;
  String categoryId;
  bool reviewed;
  Map<String, String> description;
  String icon;
  HashSet<String> unitIds;

  Habit({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.reviewed,
    required this.description,
    required this.icon,
    required this.unitIds,
  });
}
