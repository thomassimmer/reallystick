import 'package:equatable/equatable.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';

class NotificationDataModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? url;
  final DateTime createdAt;
  final bool seen;

  const NotificationDataModel({
    required this.id,
    required this.title,
    required this.body,
    required this.url,
    required this.createdAt,
    required this.seen,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> jsonObject) {
    return NotificationDataModel(
      id: jsonObject['id'] as String,
      title: jsonObject['title'] as String,
      body: jsonObject['body'] as String,
      url: jsonObject['url'] as String?,
      createdAt: DateTime.parse(jsonObject['created_at'] as String),
      seen: jsonObject['seen'] as bool,
    );
  }

  Notification toDomain() => Notification(
        id: id,
        title: title,
        body: body,
        url: url,
        createdAt: createdAt,
        seen: seen,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        url,
        seen,
        createdAt,
      ];
}
