class HabitStatistic {
  final String habitId;
  final int participantsCount;
  final Set<MapEntry<String, int>> topAges;
  final Set<MapEntry<String, int>> topCountries;
  final Set<MapEntry<String, int>> topRegions;
  final Set<MapEntry<String, int>> topHasChildren;
  final Set<MapEntry<String, int>> topLivesInUrbanArea;
  final Set<MapEntry<String, int>> topGender;
  final Set<MapEntry<String, int>> topActivities;
  final Set<MapEntry<String, int>> topFinancialSituations;
  final Set<MapEntry<String, int>> topRelationshipStatuses;
  final Set<MapEntry<String, int>> topLevelsOfEducation;

  HabitStatistic({
    required this.habitId,
    required this.participantsCount,
    required this.topAges,
    required this.topCountries,
    required this.topRegions,
    required this.topHasChildren,
    required this.topLivesInUrbanArea,
    required this.topGender,
    required this.topActivities,
    required this.topFinancialSituations,
    required this.topRelationshipStatuses,
    required this.topLevelsOfEducation,
  });
}
