class Habit {
  String id;
  Map<String, String> shortName;
  Map<String, String> longName;
  String categoryId;
  bool reviewed;
  Map<String, String> description;
  String icon;

  Habit({
    required this.id,
    required this.shortName,
    required this.longName,
    required this.categoryId,
    required this.reviewed,
    required this.description,
    required this.icon,
  });
}
