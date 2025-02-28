class PublicMessageReport {
  final String id;
  final String messageId;
  final String reporter;
  final String reason;
  final DateTime createdAt;

  PublicMessageReport({
    required this.id,
    required this.messageId,
    required this.reporter,
    required this.reason,
    required this.createdAt,
  });
}
