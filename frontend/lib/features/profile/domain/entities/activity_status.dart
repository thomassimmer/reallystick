import 'package:flutter/material.dart';
import 'package:reallystick/i18n/app_localizations.dart';

enum ActivityStatus { student, unemployed, worker }

extension ActivityStatusExtension on ActivityStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static ActivityStatus fromString(String status) {
    try {
      return ActivityStatus.values.firstWhere(
        (activityStatus) =>
            activityStatus.toShortString().toLowerCase() ==
            status.toLowerCase(),
        orElse: () =>
            throw ArgumentError("No ActivityStatus matches '$status'"),
      );
    } catch (e) {
      return ActivityStatus.worker;
    }
  }

  String getLocalizedStatus(
    BuildContext context,
  ) {
    switch (this) {
      case ActivityStatus.student:
        return AppLocalizations.of(context)!.student;
      case ActivityStatus.unemployed:
        return AppLocalizations.of(context)!.unemployed;
      case ActivityStatus.worker:
        return AppLocalizations.of(context)!.worker;
    }
  }
}
