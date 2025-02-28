enum FinancialSituationStatus { poor, average, wealthy }

extension FinancialSituationStatusExtension on FinancialSituationStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
