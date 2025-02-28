import 'package:equatable/equatable.dart';
import 'package:reallystick/features/habits/domain/entities/habit_statistic.dart';

class HabitStatisticDataModel extends Equatable {
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
  final List<String> challenges;

  const HabitStatisticDataModel({
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
    required this.challenges,
  });

  factory HabitStatisticDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return HabitStatisticDataModel(
      habitId: jsonObject['habit_id'] as String,
      participantsCount: jsonObject['participants_count'] as int,
      topAges: _parseCategoryData(jsonObject['top_ages']),
      topCountries: _parseCategoryData(jsonObject['top_countries']),
      topRegions: _parseCategoryData(jsonObject['top_regions']),
      topHasChildren: _parseCategoryData(jsonObject['top_has_children']),
      topLivesInUrbanArea:
          _parseCategoryData(jsonObject['top_lives_in_urban_area']),
      topGender: _parseCategoryData(jsonObject['top_gender']),
      topActivities: _parseCategoryData(jsonObject['top_activities']),
      topFinancialSituations:
          _parseCategoryData(jsonObject['top_financial_situations']),
      topRelationshipStatuses:
          _parseCategoryData(jsonObject['top_relationship_statuses']),
      topLevelsOfEducation:
          _parseCategoryData(jsonObject['top_levels_of_education']),
      challenges: (jsonObject['challenges'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
    );
  }

  // Helper method to parse category data from JSON
  static Set<MapEntry<String, int>> _parseCategoryData(List<dynamic> jsonList) {
    return jsonList.map((item) {
      final category = item[0] as String;
      final count = item[1] as int;
      return MapEntry(category, count);
    }).toSet();
  }

  // Convert the data model to the domain model
  HabitStatistic toDomain() {
    return HabitStatistic(
      habitId: habitId,
      participantsCount: participantsCount,
      topAges: topAges,
      topCountries: topCountries,
      topRegions: topRegions,
      topHasChildren: topHasChildren,
      topLivesInUrbanArea: topLivesInUrbanArea,
      topGender: topGender,
      topActivities: topActivities,
      topFinancialSituations: topFinancialSituations,
      topRelationshipStatuses: topRelationshipStatuses,
      topLevelsOfEducation: topLevelsOfEducation,
      challenges: challenges,
    );
  }

  @override
  List<Object?> get props => [
        habitId,
        participantsCount,
        topAges,
        topCountries,
        topRegions,
        topHasChildren,
        topLivesInUrbanArea,
        topGender,
        topActivities,
        topFinancialSituations,
        topRelationshipStatuses,
        topLevelsOfEducation,
        challenges,
      ];
}
