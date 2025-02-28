class Unit {
  String id;
  Map<String, String> shortName;
  Map<String, Map<String, String>> longName;

  Unit({
    required this.id,
    required this.shortName,
    required this.longName,
  });
}
