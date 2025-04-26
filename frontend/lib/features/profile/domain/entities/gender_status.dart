import 'package:flutter/material.dart';
import 'package:reallystick/i18n/app_localizations.dart';

enum GenderStatus { male, female, other }

extension GenderStatusExtension on GenderStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static GenderStatus fromString(String status) {
    try {
      return GenderStatus.values.firstWhere(
        (genderStatus) =>
            genderStatus.toShortString().toLowerCase() == status.toLowerCase(),
        orElse: () => throw ArgumentError("No GenderStatus matches '$status'"),
      );
    } catch (e) {
      return GenderStatus.male;
    }
  }

  String getLocalizedStatus(BuildContext context) {
    switch (this) {
      case GenderStatus.male:
        return AppLocalizations.of(context)!.male;
      case GenderStatus.female:
        return AppLocalizations.of(context)!.female;
      case GenderStatus.other:
        return AppLocalizations.of(context)!.other;
    }
  }
}
