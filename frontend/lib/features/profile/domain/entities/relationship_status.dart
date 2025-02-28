enum RelationshipStatus { single, couple }

extension RelationshipStatusExtension on RelationshipStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
