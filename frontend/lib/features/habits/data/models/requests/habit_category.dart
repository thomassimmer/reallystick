class HabitCategoryCreateRequestModel {
  final Map<String, String> name;
  final String icon;

  const HabitCategoryCreateRequestModel({
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}

class HabitCategoryUpdateRequestModel {
  final Map<String, String> name;
  final String icon;

  const HabitCategoryUpdateRequestModel({
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}
