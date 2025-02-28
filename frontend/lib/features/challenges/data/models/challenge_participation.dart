import 'package:equatable/equatable.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';

class ChallengeParticipationDataModel extends Equatable {
  final String id;
  final String userId;
  final String challengeId;
  final String color;
  final DateTime startDate;

  const ChallengeParticipationDataModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.color,
    required this.startDate,
  });

  factory ChallengeParticipationDataModel.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipationDataModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      color: json['color'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
    );
  }

  ChallengeParticipation toDomain() => ChallengeParticipation(
        id: id,
        userId: userId,
        challengeId: challengeId,
        color: color,
        startDate: startDate,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        challengeId,
        color,
        startDate,
      ];
}
