class PublicMessageReportCreateRequestModel {
  final String messageId;
  final String reason;

  const PublicMessageReportCreateRequestModel({
    required this.messageId,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'reason': reason,
    };
  }
}
