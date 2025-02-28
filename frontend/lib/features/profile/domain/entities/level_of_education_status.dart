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
}
