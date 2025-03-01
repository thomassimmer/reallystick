class Statistics {
  final String code;
  final int userCount;
  final int userTokenCount;
  final int unitCount;
  final int habitCategoryCount;
  final int habitCount;
  final int challengeCount;
  final int habitParticipationCount;
  final int challengeParticipationCount;
  final int habitDailyTrackingCount;
  final int challengeDailyTrackingCount;
  final int notificationCount;
  final int privateDiscussionCount;
  final int privateMessageCount;
  final int publicMessageCount;
  final int publicMessageLikeCount;
  final int publicMessageReportCount;
  final int activeSocketCount;

  Statistics({
    required this.code,
    required this.userCount,
    required this.userTokenCount,
    required this.unitCount,
    required this.habitCategoryCount,
    required this.habitCount,
    required this.challengeCount,
    required this.habitParticipationCount,
    required this.challengeParticipationCount,
    required this.habitDailyTrackingCount,
    required this.challengeDailyTrackingCount,
    required this.notificationCount,
    required this.privateDiscussionCount,
    required this.privateMessageCount,
    required this.publicMessageCount,
    required this.publicMessageLikeCount,
    required this.publicMessageReportCount,
    required this.activeSocketCount,
  });
}
