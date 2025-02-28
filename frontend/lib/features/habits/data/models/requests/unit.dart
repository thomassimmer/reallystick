class UnitUpdateRequestModel {
  final Map<String, String> shortName;
  final Map<String, Map<String, String>> longName;

  const UnitUpdateRequestModel({
    required this.shortName,
    required this.longName,
  });

  Map<String, dynamic> toJson() {
    return {
      'short_name': shortName,
      'long_name': longName,
    };
  }
}

class UnitCreateRequestModel {
  final Map<String, String> shortName;
  final Map<String, Map<String, String>> longName;

  const UnitCreateRequestModel({
    required this.shortName,
    required this.longName,
  });

  Map<String, dynamic> toJson() {
    return {
      'short_name': shortName,
      'long_name': longName,
    };
  }
}
