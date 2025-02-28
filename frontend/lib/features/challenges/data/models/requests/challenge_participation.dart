class ChallengeParticipationUpdateRequestModel {
  final String color;
  final DateTime startDate;

  const ChallengeParticipationUpdateRequestModel({
    required this.color,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'start_date': startDate.toUtc().toIso8601String(),
    };
  }
}

class ChallengeParticipationCreateRequestModel {
  final String challengeId;
  final String color;
  final DateTime startDate;

  const ChallengeParticipationCreateRequestModel({
    required this.challengeId,
    required this.color,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'color': color,
      'start_date': startDate.toUtc().toIso8601String(),
    };
  }
}
