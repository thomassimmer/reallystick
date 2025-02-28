class PrivateDiscussionCreateRequestModel {
  final String color;
  final String recipient;

  const PrivateDiscussionCreateRequestModel({
    required this.color,
    required this.recipient,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'recipient': recipient,
    };
  }
}
