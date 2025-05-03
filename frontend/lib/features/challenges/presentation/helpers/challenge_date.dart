import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_participation.dart';

// Returns true if challenge finished yesterday or before.
// Return false if challenge has no daily tracking yet.
bool checkIfChallengeIsFinished({
  required List<ChallengeDailyTracking> challengeDailyTrackings,
  required DateTime? challengeStartDate,
  required ChallengeParticipation? challengeParticipation,
}) {
  if (challengeDailyTrackings.isEmpty || challengeParticipation == null) {
    return false;
  }

  final today = DateTime.now();
  final yesterday = today.subtract(Duration(days: 1));

  challengeDailyTrackings
      .sort((a, b) => a.dayOfProgram.compareTo(b.dayOfProgram));

  final lastDailyTracking = challengeDailyTrackings.last;

  final challengeEndDate = challengeStartDate != null
      ? challengeStartDate.add(Duration(days: lastDailyTracking.dayOfProgram))
      : challengeParticipation.startDate
          .add(Duration(days: lastDailyTracking.dayOfProgram));

  return yesterday.compareTo(challengeEndDate) >= 0;
}
