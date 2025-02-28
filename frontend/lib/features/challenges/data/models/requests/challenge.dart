class ChallengeUpdateRequestModel {
  final Map<String, String> name;
  final Map<String, String> description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String icon;

  const ChallengeUpdateRequestModel({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate,
      'icon': icon,
    };
  }
}

class ChallengeCreateRequestModel {
  final Map<String, String> name;
  final Map<String, String> description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String icon;

  const ChallengeCreateRequestModel({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate,
      'icon': icon,
    };
  }
}
