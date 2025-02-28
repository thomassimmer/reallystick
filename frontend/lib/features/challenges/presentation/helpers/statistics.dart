import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';
import 'package:reallystick/features/profile/domain/entities/activity_status.dart';
import 'package:reallystick/features/profile/domain/entities/financial_situation_status.dart';
import 'package:reallystick/features/profile/domain/entities/level_of_education_status.dart';
import 'package:reallystick/features/profile/domain/entities/relationship_status.dart';

String computeTopAgesText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topAgesAsList = challengeStatistic.topAges.toList();
  topAgesAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topAgesText = '';

  for (final (index, age) in topAgesAsList.indexed) {
    category = age.key;
    percentage = 100 * age.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topAgesText += '\n';
    }
    topAgesText += '${index + 1}. $category ($percentage %)';
  }

  return topAgesText;
}

String computeTopCountriesText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topCountriesAsList = challengeStatistic.topCountries.toList();
  topCountriesAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topCountriesText = '';

  for (final (index, country) in topCountriesAsList.indexed) {
    category = country.key;
    percentage = 100 * country.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topCountriesText += '\n';
    }
    topCountriesText += '${index + 1}. $category ($percentage %)';
  }

  return topCountriesText;
}

String computeTopRegionsText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topRegionsAsList = challengeStatistic.topRegions.toList();
  topRegionsAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topRegionsText = '';

  for (final (index, region) in topRegionsAsList.indexed) {
    category = region.key;
    percentage = 100 * region.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topRegionsText += '\n';
    }
    topRegionsText += '${index + 1}. $category ($percentage %)';
  }

  return topRegionsText;
}

String computeTopHasChildrenText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topHasChildrenAsList = challengeStatistic.topHasChildren.toList();
  topHasChildrenAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topHasChildrenText = '';

  for (final (index, hasChildren) in topHasChildrenAsList.indexed) {
    category = hasChildren.key == "Yes"
        ? AppLocalizations.of(context)!.peopleWithChildren
        : AppLocalizations.of(context)!.peopleWithoutChildren;
    percentage =
        100 * hasChildren.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topHasChildrenText += '\n';
    }
    topHasChildrenText += '${index + 1}. $category ($percentage %)';
  }

  return topHasChildrenText;
}

String computeTopLivesInUrbanAreaText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topLivesInUrbanAreaAsList =
      challengeStatistic.topLivesInUrbanArea.toList();
  topLivesInUrbanAreaAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topLivesInUrbanAreaText = '';

  for (final (index, livesInUrbanArea) in topLivesInUrbanAreaAsList.indexed) {
    category = livesInUrbanArea.key == "Yes"
        ? AppLocalizations.of(context)!.livingInUrbanArea
        : AppLocalizations.of(context)!.livingInRuralArea;
    percentage =
        100 * livesInUrbanArea.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topLivesInUrbanAreaText += '\n';
    }
    topLivesInUrbanAreaText += '${index + 1}. $category ($percentage %)';
  }

  return topLivesInUrbanAreaText;
}

String computeTopGenderText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topGenderAsList = challengeStatistic.topGender.toList();
  topGenderAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topGenderText = '';

  for (final (index, gender) in topGenderAsList.indexed) {
    category = gender.key == "male"
        ? AppLocalizations.of(context)!.males
        : AppLocalizations.of(context)!.females;
    percentage = 100 * gender.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topGenderText += '\n';
    }
    topGenderText += '${index + 1}. $category ($percentage %)';
  }

  return topGenderText;
}

String computeTopActivitiesText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topActitivtiesAsList = challengeStatistic.topActivities.toList();
  topActitivtiesAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topActivitiesText = '';

  for (final (index, activity) in topActitivtiesAsList.indexed) {
    category = ActivityStatusExtension.fromString(activity.key)
        .getLocalizedStatus(context);
    percentage = 100 * activity.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topActivitiesText += '\n';
    }
    topActivitiesText += '${index + 1}. $category ($percentage %)';
  }

  return topActivitiesText;
}

String computeTopFinancialSituationsText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topFinancialSituationsAsList =
      challengeStatistic.topFinancialSituations.toList();
  topFinancialSituationsAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topFinancialSituationsText = '';

  for (final (index, financialSituation)
      in topFinancialSituationsAsList.indexed) {
    category =
        FinancialSituationStatusExtension.fromString(financialSituation.key)
            .getLocalizedStatus(context);
    percentage =
        100 * financialSituation.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topFinancialSituationsText += '\n';
    }
    topFinancialSituationsText += '${index + 1}. $category ($percentage %)';
  }

  return topFinancialSituationsText;
}

String computeTopRelationshipStatusesText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topRelationshipStatusesAsList =
      challengeStatistic.topRelationshipStatuses.toList();
  topRelationshipStatusesAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topRelationshipStatusesText = '';

  for (final (index, relationshipStatus)
      in topRelationshipStatusesAsList.indexed) {
    category = RelationshipStatusExtension.fromString(relationshipStatus.key)
        .getLocalizedStatus(context);
    percentage =
        100 * relationshipStatus.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topRelationshipStatusesText += '\n';
    }
    topRelationshipStatusesText += '${index + 1}. $category ($percentage %)';
  }

  return topRelationshipStatusesText;
}

String computeTopLevelsOfEducationText(
    BuildContext context, ChallengeStatistic challengeStatistic) {
  final topLevelsOfEducationAsList =
      challengeStatistic.topLevelsOfEducation.toList();
  topLevelsOfEducationAsList.sort((a, b) => b.value.compareTo(a.value));

  String? category;
  int? percentage;

  String topLevelsOfEducationText = '';

  for (final (index, levelOfEducation) in topLevelsOfEducationAsList.indexed) {
    category = LevelOfEducationStatusExtension.fromString(levelOfEducation.key)
        .getLocalizedStatus(context);
    percentage =
        100 * levelOfEducation.value ~/ challengeStatistic.participantsCount;
    if (index > 0) {
      topLevelsOfEducationText += '\n';
    }
    topLevelsOfEducationText += '${index + 1}. $category ($percentage %)';
  }

  return topLevelsOfEducationText;
}
