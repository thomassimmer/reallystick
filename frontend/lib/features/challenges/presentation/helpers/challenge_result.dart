import 'package:reallystick/core/constants/unit_conversion.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';

bool _habitTrackingMeetsChallengeTracking(
  HabitDailyTracking h,
  ChallengeDailyTracking c,
  Map<String, Unit> units,
) {
  final expectedWeight = normalizeUnit(
    c.weight.toDouble(),
    c.weightUnitId,
    units,
  );
  final actualWeight = normalizeUnit(
    h.weight.toDouble(),
    h.weightUnitId,
    units,
  );

  if (actualWeight < expectedWeight) return false;

  final actualQuantity = normalizeUnit(
    h.quantityPerSet * h.quantityOfSet,
    h.unitId,
    units,
  );
  final expectedQuantity = normalizeUnit(
    c.quantityPerSet * c.quantityOfSet,
    c.unitId,
    units,
  );

  return actualQuantity >= expectedQuantity;
}

Map<String, bool> matchHabitTrackingsToChallengeTrackings(
  List<ChallengeDailyTracking> challengeDailyTrackings,
  List<HabitDailyTracking> habitDailyTrackings,
  Map<String, Unit> units,
) {
  final usedHabitDailyTrackingIds = <String>{};
  final result = <String, bool>{};

  // Normalize and sort challenges
  challengeDailyTrackings.sort((a, b) {
    final aQuantity = normalizeUnit(
      a.quantityOfSet * a.quantityPerSet,
      a.unitId,
      units,
    );
    final bQuantity = normalizeUnit(
      b.quantityOfSet * b.quantityPerSet,
      b.unitId,
      units,
    );

    final aWeight = normalizeUnit(
      a.weight.toDouble(),
      a.weightUnitId,
      units,
    );
    final bWeight = normalizeUnit(
      b.weight.toDouble(),
      b.weightUnitId,
      units,
    );

    final aEffort = aWeight * aQuantity;
    final bEffort = bWeight * bQuantity;

    return bEffort.compareTo(aEffort); // descending
  });

  // Normalize and sort habits
  habitDailyTrackings.sort((a, b) {
    final aQuantity = normalizeUnit(
      a.quantityOfSet * a.quantityPerSet,
      a.unitId,
      units,
    );
    final bQuantity = normalizeUnit(
      b.quantityOfSet * b.quantityPerSet,
      b.unitId,
      units,
    );

    final aWeight = normalizeUnit(
      a.weight.toDouble(),
      a.weightUnitId,
      units,
    );
    final bWeight = normalizeUnit(
      b.weight.toDouble(),
      b.weightUnitId,
      units,
    );

    final aEffort = aWeight * aQuantity;
    final bEffort = bWeight * bQuantity;

    return bEffort.compareTo(aEffort); // descending
  });

  for (final challengeDailyTracking in challengeDailyTrackings) {
    final expectedQuantity = normalizeUnit(
      challengeDailyTracking.quantityOfSet *
          challengeDailyTracking.quantityPerSet,
      challengeDailyTracking.unitId,
      units,
    );

    final expectedWeight = normalizeUnit(
      challengeDailyTracking.weight.toDouble(),
      challengeDailyTracking.weightUnitId,
      units,
    );

    if (expectedQuantity == 0) {
      // Check that no habit entry shows positive effort for this habit
      final hasNonZeroHabit = habitDailyTrackings.any((h) {
        if (h.challengeDailyTracking != null &&
            h.challengeDailyTracking != challengeDailyTracking.id) {
          return false; // skip others
        }

        final quantity = normalizeUnit(
          h.quantityOfSet * h.quantityPerSet,
          h.unitId,
          units,
        );

        return quantity > 0;
      });

      result[challengeDailyTracking.id] = !hasNonZeroHabit;
      continue;
    }

    // 1. Try to find an explicitly linked entry
    final linked = habitDailyTrackings
        .where(
          (h) => h.challengeDailyTracking == challengeDailyTracking.id,
        )
        .firstOrNull;

    if (linked != null &&
        _habitTrackingMeetsChallengeTracking(
            linked, challengeDailyTracking, units)) {
      usedHabitDailyTrackingIds.add(linked.id);
      result[challengeDailyTracking.id] = true;
      continue;
    }

    // 2. Try to accumulate from unlinked & unused habits
    double totalQuantity = 0;
    final usedForThisChallenge = <String>{};

    for (final h in habitDailyTrackings) {
      if (h.challengeDailyTracking != null) continue;
      if (usedHabitDailyTrackingIds.contains(h.id)) continue;

      final weight = normalizeUnit(
        h.weight.toDouble(),
        h.weightUnitId,
        units,
      );

      if (weight >= expectedWeight) {
        totalQuantity += normalizeUnit(
          h.quantityOfSet * h.quantityPerSet,
          h.unitId,
          units,
        );
        usedForThisChallenge.add(h.id);
      }

      if (totalQuantity >= expectedQuantity) {
        // Enough accumulated to meet the challenge
        usedHabitDailyTrackingIds.addAll(usedForThisChallenge);
        result[challengeDailyTracking.id] = true;
        break;
      }
    }

    result[challengeDailyTracking.id] =
        result[challengeDailyTracking.id] ?? false;
  }

  return result;
}
