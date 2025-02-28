class Challenge {
  String id;
  String creator;
  Map<String, String> name;
  Map<String, String> description;
  String icon;
  DateTime? startDate;
  DateTime? endDate;
  bool deleted;

  Challenge({
    required this.id,
    required this.creator,
    required this.name,
    required this.description,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.deleted,
  });
}
