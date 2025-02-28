class Notification {
  String id;
  String title;
  String body;
  String? url;
  DateTime createdAt;
  bool seen;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.url,
    required this.createdAt,
    required this.seen,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? url,
    DateTime? createdAt,
    bool? seen,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      url: url ?? this.url,
      seen: seen ?? this.seen,
    );
  }
}
