import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';

abstract class ChallengeState extends Equatable {
  final Message? message;

  const ChallengeState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ChallengesLoading extends ChallengeState {
  const ChallengesLoading({
    super.message,
  });
}

class ChallengesFailed extends ChallengeState {
  const ChallengesFailed({
    super.message,
  });
}

class ChallengesLoaded extends ChallengeState {
  final List<ChallengeParticipation> challengeParticipations;
  final Map<String, Challenge> challenges;
  final Map<String, List<ChallengeDailyTracking>> challengeDailyTrackings;
  final Map<String, ChallengeStatistic> challengeStatistics;
  final Challenge? newlyCreatedChallenge;
  final Challenge? newlyUpdatedChallenge;
  final String? notFoundChallenge;

  const ChallengesLoaded({
    super.message,
    required this.challengeParticipations,
    required this.challenges,
    required this.challengeDailyTrackings,
    required this.challengeStatistics,
    this.newlyCreatedChallenge,
    this.newlyUpdatedChallenge,
    this.notFoundChallenge,
  });

  @override
  List<Object?> get props => [
        message,
        challengeDailyTrackings,
        challengeParticipations,
        challenges,
        challengeStatistics,
        newlyCreatedChallenge,
        newlyUpdatedChallenge,
        notFoundChallenge,
      ];
}
