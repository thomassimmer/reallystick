enum ActivityStatus { student, unemployed, worker }

extension ActivityStatusExtension on ActivityStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
