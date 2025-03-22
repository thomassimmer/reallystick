import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';

bool checkIfChallengeIsFinished({
  required List<ChallengeDailyTracking> challengeDailyTrackings,
  required DateTime? challengeStartDate,
  required ChallengeParticipation? challengeParticipation,
}) {
  if (challengeDailyTrackings.isEmpty || challengeParticipation == null) {
    return false;
  }

  final today = DateTime.now();

  challengeDailyTrackings
      .sort((a, b) => a.dayOfProgram.compareTo(b.dayOfProgram));

  final lastDailyTracking = challengeDailyTrackings.last;

  final challengeEndDate = challengeStartDate != null
      ? challengeStartDate.add(Duration(days: lastDailyTracking.dayOfProgram))
      : challengeParticipation.startDate
          .add(Duration(days: lastDailyTracking.dayOfProgram));

  return today.compareTo(challengeEndDate) >= 0;
}
