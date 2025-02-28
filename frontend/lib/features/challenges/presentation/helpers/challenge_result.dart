import 'package:reallystick/core/constants/unit_conversion.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';

bool checkIfDailyObjectiveWasDone(ChallengeDailyTracking challengeDailyTracking,
    List<HabitDailyTracking> habitDailyTrackings, Map<String, Unit> units) {
  if (challengeDailyTracking.quantityOfSet == 0) {
    // We should'nt do any non-zero quantity for this habit

    for (final hdt in habitDailyTrackings) {
      if (hdt.quantityOfSet > 0) {
        return false;
      }
    }

    return true;
  } else {
    final totalQuantityExpected = challengeDailyTracking.quantityOfSet *
        challengeDailyTracking.quantityPerSet;
    final weightExpected = normalizeUnit(
      challengeDailyTracking.weight,
      challengeDailyTracking.unitId,
      units,
    );
    int totalQuantityFound = 0;

    // We should do at least the total quantity expected for this habit

    for (final hdt in habitDailyTrackings) {
      final weightFound = normalizeUnit(
        hdt.weight,
        hdt.unitId,
        units,
      );

      if (weightFound >= weightExpected) {
        totalQuantityFound += hdt.quantityPerSet * hdt.quantityOfSet;
      }
    }

    return totalQuantityFound >= totalQuantityExpected;
  }
}
