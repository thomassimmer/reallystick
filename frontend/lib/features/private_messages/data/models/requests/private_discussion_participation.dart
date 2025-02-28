class PrivateDiscussionParticipationUpdateRequestModel {
  final bool hasBlocked;
  final String color;

  const PrivateDiscussionParticipationUpdateRequestModel({
    required this.hasBlocked,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'has_blocked': hasBlocked,
      'color': color,
    };
  }
}
