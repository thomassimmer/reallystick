import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum LevelOfEducationStatus {
  highSchoolOrLess,
  highSchoolPlusOneOrTwoYears,
  highSchoolPlusThreeOrFourYears,
  highSchoolPlusFiveOrMoreYears
}

extension LevelOfEducationStatusExtension on LevelOfEducationStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static LevelOfEducationStatus fromString(String status) {
    try {
      return LevelOfEducationStatus.values.firstWhere(
        (levelOfEducationStatus) =>
            levelOfEducationStatus.toShortString().toLowerCase() ==
            status.toLowerCase(),
        orElse: () =>
            throw ArgumentError("No LevelOfEducationStatus matches '$status'"),
      );
    } catch (e) {
      return LevelOfEducationStatus.highSchoolOrLess;
    }
  }

  String getLocalizedStatus(BuildContext context) {
    switch (this) {
      case LevelOfEducationStatus.highSchoolOrLess:
        return AppLocalizations.of(context)!.highSchoolOrLess;
      case LevelOfEducationStatus.highSchoolPlusOneOrTwoYears:
        return AppLocalizations.of(context)!.highSchoolPlusOneOrTwoYears;
      case LevelOfEducationStatus.highSchoolPlusThreeOrFourYears:
        return AppLocalizations.of(context)!.highSchoolPlusThreeOrFourYears;
      case LevelOfEducationStatus.highSchoolPlusFiveOrMoreYears:
        return AppLocalizations.of(context)!.highSchoolPlusFiveOrMoreYears;
    }
  }
}
