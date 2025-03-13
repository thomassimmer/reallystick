import 'package:equatable/equatable.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';

class ChallengeParticipationDataModel extends Equatable {
  final String id;
  final String userId;
  final String challengeId;
  final String color;
  final DateTime startDate;
  final bool notificationsReminderEnabled;
  final String? reminderTime;
  final String? reminderBody;

  const ChallengeParticipationDataModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.color,
    required this.startDate,
    required this.notificationsReminderEnabled,
    required this.reminderTime,
    required this.reminderBody,
  });

  factory ChallengeParticipationDataModel.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipationDataModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      color: json['color'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      notificationsReminderEnabled:
          json['notifications_reminder_enabled'] as bool,
      reminderTime: json['reminder_time'] as String?,
      reminderBody: json['reminder_body'] as String?,
    );
  }

  ChallengeParticipation toDomain() => ChallengeParticipation(
        id: id,
        userId: userId,
        challengeId: challengeId,
        color: color,
        startDate: startDate,
        notificationsReminderEnabled: notificationsReminderEnabled,
        reminderTime: reminderTime,
        reminderBody: reminderBody,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        challengeId,
        color,
        startDate,
        notificationsReminderEnabled,
        reminderTime,
        reminderBody,
      ];
}
