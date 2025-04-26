import 'package:flutter/material.dart';
import 'package:reallystick/i18n/app_localizations.dart';

enum RelationshipStatus { single, couple }

extension RelationshipStatusExtension on RelationshipStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static RelationshipStatus fromString(String status) {
    try {
      return RelationshipStatus.values.firstWhere(
        (relationshipStatus) =>
            relationshipStatus.toShortString().toLowerCase() ==
            status.toLowerCase(),
        orElse: () =>
            throw ArgumentError("No RelationshipStatus matches '$status'"),
      );
    } catch (e) {
      return RelationshipStatus.single;
    }
  }

  String getLocalizedStatus(BuildContext context) {
    switch (this) {
      case RelationshipStatus.single:
        return AppLocalizations.of(context)!.relationshipStatusSingle;
      case RelationshipStatus.couple:
        return AppLocalizations.of(context)!.relationshipStatusCouple;
    }
  }
}
