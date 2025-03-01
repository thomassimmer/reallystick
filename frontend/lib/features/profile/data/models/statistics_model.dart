import 'package:equatable/equatable.dart';
import 'package:reallystick/features/profile/domain/entities/statistics.dart';

class StatisticsDataModel extends Equatable {
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

  const StatisticsDataModel({
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

  Statistics toDomain() => Statistics(
        code: code,
        userCount: userCount,
        userTokenCount: userTokenCount,
        unitCount: unitCount,
        habitCategoryCount: habitCategoryCount,
        habitCount: habitCount,
        challengeCount: challengeCount,
        habitParticipationCount: habitParticipationCount,
        challengeParticipationCount: challengeParticipationCount,
        habitDailyTrackingCount: habitDailyTrackingCount,
        challengeDailyTrackingCount: challengeDailyTrackingCount,
        notificationCount: notificationCount,
        privateDiscussionCount: privateDiscussionCount,
        privateMessageCount: privateMessageCount,
        publicMessageCount: publicMessageCount,
        publicMessageLikeCount: publicMessageLikeCount,
        publicMessageReportCount: publicMessageReportCount,
        activeSocketCount: activeSocketCount,
      );

  // Factory method for creating a StatisticsModel from a JSON map
  factory StatisticsDataModel.fromJson(Map<String, dynamic> json) {
    return StatisticsDataModel(
      code: json['code'] as String,
      userCount: json['user_count'] as int,
      userTokenCount: json['user_token_count'] as int,
      unitCount: json['unit_count'] as int,
      habitCategoryCount: json['habit_category_count'] as int,
      habitCount: json['habit_count'] as int,
      challengeCount: json['challenge_count'] as int,
      habitParticipationCount: json['habit_participation_count'] as int,
      challengeParticipationCount: json['challenge_participation_count'] as int,
      habitDailyTrackingCount: json['habit_daily_tracking_count'] as int,
      challengeDailyTrackingCount:
          json['challenge_daily_tracking_count'] as int,
      notificationCount: json['notification_count'] as int,
      privateDiscussionCount: json['private_discussion_count'] as int,
      privateMessageCount: json['private_message_count'] as int,
      publicMessageCount: json['public_message_count'] as int,
      publicMessageLikeCount: json['public_message_like_count'] as int,
      publicMessageReportCount: json['public_message_report_count'] as int,
      activeSocketCount: json['active_socket_count'] as int,
    );
  }

  // Method for converting the StatisticsModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'user_count': userCount,
      'user_token_count': userTokenCount,
      'unit_count': unitCount,
      'habit_category_count': habitCategoryCount,
      'habit_count': habitCount,
      'challenge_count': challengeCount,
      'habit_participation_count': habitParticipationCount,
      'challenge_participation_count': challengeParticipationCount,
      'habit_daily_tracking_count': habitDailyTrackingCount,
      'challenge_daily_tracking_count': challengeDailyTrackingCount,
      'notification_count': notificationCount,
      'private_discussion_count': privateDiscussionCount,
      'private_message_count': privateMessageCount,
      'public_message_count': publicMessageCount,
      'public_message_like_count': publicMessageLikeCount,
      'public_message_report_count': publicMessageReportCount,
      'active_socket_count': activeSocketCount,
    };
  }

  @override
  List<Object?> get props => [
        code,
        userCount,
        userTokenCount,
        unitCount,
        habitCategoryCount,
        habitCount,
        challengeCount,
        habitParticipationCount,
        challengeParticipationCount,
        habitDailyTrackingCount,
        challengeDailyTrackingCount,
        notificationCount,
        privateDiscussionCount,
        privateMessageCount,
        publicMessageCount,
        publicMessageLikeCount,
        publicMessageReportCount,
        activeSocketCount,
      ];
}
