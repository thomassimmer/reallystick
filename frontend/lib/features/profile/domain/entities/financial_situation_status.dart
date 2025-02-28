import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum FinancialSituationStatus { poor, average, wealthy }

extension FinancialSituationStatusExtension on FinancialSituationStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static FinancialSituationStatus fromString(String status) {
    try {
      return FinancialSituationStatus.values.firstWhere(
        (financialSituationStatus) =>
            financialSituationStatus.toShortString().toLowerCase() ==
            status.toLowerCase(),
        orElse: () => throw ArgumentError(
            "No FinancialSituationStatus matches '$status'"),
      );
    } catch (e) {
      return FinancialSituationStatus.poor;
    }
  }

  String getLocalizedStatus(BuildContext context) {
    switch (this) {
      case FinancialSituationStatus.poor:
        return AppLocalizations.of(context)!.poor;
      case FinancialSituationStatus.average:
        return AppLocalizations.of(context)!.average;
      case FinancialSituationStatus.wealthy:
        return AppLocalizations.of(context)!.wealthy;
    }
  }
}
