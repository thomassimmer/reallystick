enum GenderStatus { male, female, other }

extension GenderStatusExtension on GenderStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
